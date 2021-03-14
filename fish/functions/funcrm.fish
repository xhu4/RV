# Defined via `source`
function funcrm --wraps='functions -e $argv[1] && rm -f ~/.config/figh/functions/$argv[1].fish' --description 'alias funcrm=functions -e $argv[1] && rm -f ~/.config/figh/functions/$argv[1].fish'
  functions -e $argv[1] && rm -f ~/.config/figh/functions/$argv[1].fish $argv; 
end
