# Defined via `source`
function erc --wraps=' /home/xihu/.config/omf/init.fish' --wraps='nvim /home/xihu/.config/omf/init.fish' --wraps='$EDITOR $OMF_CONFIG/init.fish' --description 'alias erc=$EDITOR $OMF_CONFIG/init.fish'
  $EDITOR $OMF_CONFIG/init.fish $argv; 
end
