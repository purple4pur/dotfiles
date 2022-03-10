function sapt --wraps='sudo aptitude' --description 'alias sapt sudo aptitude'
  sudo aptitude $argv; 
end
