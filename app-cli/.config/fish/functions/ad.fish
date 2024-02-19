function ad --description "Advanced file, better make new file"
  function mkfile
    set file $argv[1]
    switch $file
    case "*/"
      mkdir -p $file
    case "*"
      mkdir -p (dirname "$file")
      touch $file
      ;;
    end
  end

  for file in $argv
    mkfile $file
  end
end

function ade --description "create new file, then edit it with nvim"
  set file $argv[1]
  mkdir -p (dirname "$file")
  touch $file
  nvim $file
end
