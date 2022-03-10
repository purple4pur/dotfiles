function glg --wraps='git log --all --graph --oneline' --description 'alias glg git log --all --graph --oneline'
  git log --all --graph --oneline $argv; 
end
