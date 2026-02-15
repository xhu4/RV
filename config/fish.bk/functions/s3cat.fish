# Defined in /tmp/fish.5fZwO0/s3cat.fish @ line 2
function s3cat --wraps='aws s3 cp  /tmp/s3cat && cat /tmp/s3cat' --description 'alias s3cat=aws s3 cp  /tmp/s3cat && cat /tmp/s3cat'
  aws s3 cp $argv /tmp/s3cat && cat /tmp/s3cat; 
end
