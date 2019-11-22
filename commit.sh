# /bin/bash
git add . | git status --porcelain | gawk -F $' ' '{print $2}' | xargs echo "add file:"  | xargs -I % git commit -m "%"
