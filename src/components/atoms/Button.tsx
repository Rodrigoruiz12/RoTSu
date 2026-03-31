import React, { ButtonHTMLAttributes } from 'react';

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'outline';
  fullWidth?: boolean;
}

export const Button: React.FC<ButtonProps> = ({ 
  children, 
  variant = 'primary', 
  fullWidth = false,
  className = '',
  ...props 
}) => {
  // Estilos base compartidos
  const baseStyles = "px-6 py-3 rounded-md font-medium transition-all duration-300 transform hover:scale-105 active:scale-95";
  
  // Variantes de color
  const variants = {
    primary: "bg-emerald-500 text-white hover:bg-emerald-600 shadow-[0_0_10px_rgba(16,185,129,0.4)]",
    secondary: "bg-[#333333] text-white hover:bg-[#444444]",
    outline: "border-2 border-emerald-500 text-emerald-400 hover:bg-emerald-500 hover:text-white"
  };

  const widthClass = fullWidth ? "w-full" : "";

  return (
    <button 
      className={`${baseStyles} ${variants[variant]} ${widthClass} ${className}`}
      {...props}
    >
      {children}
    </button>
  );
};
