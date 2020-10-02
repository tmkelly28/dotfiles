open_where_regex() {
  git grep $1 | awk '{ print $1 }' | sed s/:// | xargs nvim
}

