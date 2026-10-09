



hoid_task_ensure_line() {

	hoid script stdin: <<'EOF'
function ensure-line() {
	file=$1
	line=$2
	grep -xqF "$line" "$file" || echo "$line" >> "$file"
}

EOF

}