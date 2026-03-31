import * as Lucide from 'lucide-react';
console.log(Object.keys(Lucide).filter(k => 
  k.toLowerCase().includes('twitter') || 
  k.toLowerCase().includes('linkedin') || 
  k.toLowerCase().includes('mail') || 
  k.toLowerCase().includes('github')
));
