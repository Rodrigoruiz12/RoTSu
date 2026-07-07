# Par de llaves SSH para acceder a la EC2 (OPCIONAL, solo si enable_ssh_access=true)
# Recomendado: usar SSM Session Manager en lugar de SSH (mas seguro, sin puerto 22)

resource "tls_private_key" "k3s" {
  count     = var.enable_ssh_access && var.ssh_public_key == "" ? 1 : 0
  algorithm = "ED25519"
}

resource "aws_key_pair" "k3s" {
  count      = var.enable_ssh_access ? 1 : 0
  key_name   = "${var.project_name}-k8s-key"
  public_key = var.ssh_public_key != "" ? var.ssh_public_key : tls_private_key.k3s[0].public_key_openssh

  tags = {
    Name = "${var.project_name}-k8s-key"
  }
}

# Security Group para la instancia Kubernetes (kubeadm single-node)
resource "aws_security_group" "k3s" {
  name        = "${var.project_name}-k8s-sg"
  description = "Reglas para el nodo Kubernetes (kubeadm) de RoTSu"
  vpc_id      = aws_vpc.main.id

  # SSH desde el CIDR permitido (solo si enable_ssh_access=true)
  dynamic "ingress" {
    for_each = var.enable_ssh_access ? [1] : []
    content {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.allowed_ssh_cidr]
    }
  }

  # API server de Kubernetes (6443) - gestion con kubectl desde internet
  ingress {
    description = "Kubernetes API server"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # kubelet API (10250) - necesario para kubectl exec/logs
  ingress {
    description = "Kubelet API"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # kube-scheduler (10259) - componente control plane
  ingress {
    description = "kube-scheduler"
    from_port   = 10259
    to_port     = 10259
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # kube-controller-manager (10257) - componente control plane
  ingress {
    description = "kube-controller-manager"
    from_port   = 10257
    to_port     = 10257
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # NodePort range (30000-32767) - para servicios de tipo NodePort
  ingress {
    description = "Kubernetes NodePort range"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # NodePort especifico de la app RoTSu (30080) - documentado explicitamente
  ingress {
    description = "RoTSu app NodePort 30080"
    from_port   = 30080
    to_port     = 30080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP (Nginx ingress controller si se instala)
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS (Nginx ingress controller si se instala)
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Grafana NodePort (30100)
  ingress {
    description = "Grafana NodePort"
    from_port   = 30100
    to_port     = 30100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Pushgateway (9091)
  ingress {
    description = "Pushgateway"
    from_port   = 9091
    to_port     = 9091
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Salida libre"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-k8s-sg"
  }
}

# Data source AMI Ubuntu 22.04 LTS (jammy, hvm, amd64, server)
# Acepta hvm-ssd, hvm-ssd-gp3 y variantes para compatibilidad
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd*/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# IAM: NO se crean recursos IAM porque AWS Academy Learner Lab
# no permite iam:CreateRole/iam:CreateUser. El SSM agent funciona
# con el rol asumido por Vocareum (voclabs/...) que ya incluye
# SSMManagedInstanceCore implicitamente.

# Spot Instance Request (si var.use_spot = true)
resource "aws_spot_instance_request" "k3s" {
  count                  = var.use_spot ? 1 : 0
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.k3s.id]
  key_name               = var.enable_ssh_access ? aws_key_pair.k3s[0].key_name : null
  spot_price             = var.spot_max_price
  spot_type              = "persistent"
  wait_for_fulfillment   = true
  user_data              = data.template_cloudinit_config.k3s.rendered

  tags = {
    Name = "${var.project_name}-k8s-node"
  }

  # kubeadm/kubelet necesita algo de espacio en disco
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  lifecycle {
    # Evitar recreacion por drift en spot
    ignore_changes = [spot_price]
  }
}

# On-Demand Instance (si var.use_spot = false)
resource "aws_instance" "k3s" {
  count                  = var.use_spot ? 0 : 1
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.k3s.id]
  key_name               = var.enable_ssh_access ? aws_key_pair.k3s[0].key_name : null
  user_data              = data.template_cloudinit_config.k3s.rendered

  tags = {
    Name = "${var.project_name}-k8s-node"
  }

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }
}

# Cloud-init template para instalar Kubernetes via kubeadm
# Instala containerd + kubeadm + kubelet + kubectl + CNI Flannel
data "template_cloudinit_config" "k3s" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = <<-EOF
      #cloud-config
      package_update: true
      package_upgrade: false
      packages:
        - apt-transport-https
        - ca-certificates
        - curl
        - gnupg
        - containerd
      write_files:
        - path: /etc/kubernetes-install.sh
          permissions: '0755'
          owner: root:root
          content: |
            #!/usr/bin/env bash
            set -euo pipefail

            # Desactivar swap (requisito de kubelet)
            swapoff -a
            sed -ri '/\sswap\s/s/^#?/#/' /etc/fstab

            # Cargar modulos del kernel necesarios
            cat <<EOMOD | tee /etc/modules-load.d/k8s.conf
            overlay
            br_netfilter
            EOMOD
            modprobe overlay
            modprobe br_netfilter

            # Configurar sysctl para redes de Kubernetes
            cat <<EOSYSCTL | tee /etc/sysctl.d/99-kubernetes-cri.conf
            net.bridge.bridge-nf-call-iptables  = 1
            net.bridge.bridge-nf-call-ip6tables = 1
            net.ipv4.ip_forward                 = 1
            EOSYSCTL
            sysctl --system

            # Configurar containerd
            mkdir -p /etc/containerd
            containerd config default | tee /etc/containerd/config.toml >/dev/null
            sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
            systemctl restart containerd

            # Instalar kubeadm, kubelet, kubectl (version 1.31)
            curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
            echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list
            apt-get update
            apt-get install -y kubelet kubeadm kubectl
            apt-mark hold kubelet kubeadm kubectl

            # Habilitar kubectl para usuario ubuntu
            install -m 0755 -d /etc/profile.d
            echo 'export KUBECONFIG=/etc/kubernetes/admin.conf' > /etc/profile.d/kubectl.sh
            echo 'export PATH=$PATH:/usr/bin' >> /etc/profile.d/kubectl.sh

            # Obtener IP publica
            PUBLIC_IP=$(curl -sf -m 10 http://169.254.169.254/latest/meta-data/public-ipv4)
            if [ -z "$${PUBLIC_IP:-}" ]; then
              echo "ERROR: No se pudo obtener la IP publica"
              exit 1
            fi
            echo "IP publica: $$PUBLIC_IP"

            # Inicializar el cluster con kubeadm (single-node, control-plane + worker)
            kubeadm init \
              --kubernetes-version=v1.31.0 \
              --control-plane-endpoint="$${PUBLIC_IP}:6443" \
              --node-name=rotsu-control-plane \
              --pod-network-cidr=10.244.0.0/16 \
              --service-dns-domain=cluster.local \
              --skip-phases=preflight \
              --ignore-preflight-errors=NumCPU,Mem,SystemVerification,Swap

            # Habilitar scheduling de pods en el control plane (single-node)
            # Esperar a que el nodo aparezca
            export KUBECONFIG=/etc/kubernetes/admin.conf
            for i in 1 2 3 4 5 6 7 8 9 10; do
              if kubectl get nodes 2>/dev/null; then break; fi
              sleep 3
            done
            kubectl taint nodes --all node-role.kubernetes.io/control-plane- 2>/dev/null || true
            kubectl taint nodes --all node-role.kubernetes.io/master- 2>/dev/null || true

            # Instalar CNI (Flannel) - el mas ligero
            export KUBECONFIG=/etc/kubernetes/admin.conf
            kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

            # Esperar a que Flannel este listo antes de continuar
            echo "Esperando a Flannel..."
            kubectl wait --for=condition=Ready pod -n kube-flannel -l app=flannel --timeout=180s || true

            # Configurar kubeconfig para usuario ubuntu
            mkdir -p /home/ubuntu/.kube
            cp /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
            sed -i "s|server: https://127.0.0.1:6443|server: https://$${PUBLIC_IP}:6443|g" /home/ubuntu/.kube/config
            chown -R ubuntu:ubuntu /home/ubuntu/.kube
            chmod 600 /home/ubuntu/.kube/config

            # Marcar como listo
            touch /var/lib/cloud/instance/k8s-ready
            echo "Kubernetes cluster inicializado correctamente"
      runcmd:
        - bash /etc/kubernetes-install.sh
    EOF
  }
}
