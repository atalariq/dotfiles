if test -f ~/.env
  export (envsubst < ~/.env | sed '/^\s*#/d; /^$/d')
end
