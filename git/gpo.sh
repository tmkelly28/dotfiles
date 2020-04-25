gpo() {
  git push origin $(git branch | grep \* | cut -d ' ' -f2)
}
