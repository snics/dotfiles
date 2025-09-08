#!/bin/bash
# =============================================================================
# Shell Script Test File with Intentional Errors
# Tests for shellcheck and shfmt
# =============================================================================

# SHELLCHECK ERRORS

# Error: Missing quotes around variable (SC2086)
VAR="hello world"
echo $VAR

# Error: Useless echo piped to command (SC2005)
echo "test" | grep test

# Error: Variable referenced but not assigned (SC2154)
echo "$UNDEFINED_VAR"

# Error: Using $? in condition instead of if command (SC2181)
grep "pattern" file.txt
if [ $? -eq 0 ]; then
    echo "Found"
fi

# Error: Unquoted find/grep patterns (SC2185)
find . -name *.txt

# Error: Double brackets without spaces (SC1035)
if [[ "$VAR"=="test" ]]; then
    echo "Equal"
fi

# Error: Using == in [ ] (SC2039)
if [ "$VAR" == "test" ]; then
    echo "Equal"
fi

# Error: Useless cat (SC2002)
cat file.txt | grep "pattern"

# Error: Missing shebang directive at top
# (This error is already at the top, but mentioning for clarity)

# Error: Using backticks instead of $(...) (SC2006)
DATE=`date`

# Error: Array access without braces (SC2086)
arr=(one two three)
echo $arr[0]

# Error: Using -a in [ ] (SC2166)
if [ "$A" = "test" -a "$B" = "test" ]; then
    echo "Both are test"
fi

# Error: Missing quotes in array iteration (SC2068)
for item in ${arr[@]}; do
    echo "$item"
done

# Error: Incorrect function declaration
function my_func {  # Should be my_func() { or function my_func() {
    echo "Function"
}

# Error: Using single = in arithmetic comparison
if [ $VAR = 5 ]; then  # Should use -eq for numbers
    echo "Five"
fi

# SHFMT ERRORS (Formatting issues)

# Error: Inconsistent indentation
if true; then
echo "bad indent"  # Should be indented
  if false; then
      echo "inconsistent"  # Too much indentation
    fi
fi

# Error: Missing space after keywords
for i in{1..5}; do  # Missing space after 'in'
echo $i
done

# Error: Trailing whitespace      
echo "trailing spaces"    

# Error: Tab vs space mixing
	echo "tab indent"
  echo "space indent"

# Good practice violations
cd /tmp || exit  # This is actually good, but showing the alternative
cd /tmp  # Error: not handling cd failure

# Complex error: Command substitution in arithmetic context
result=$(( $(echo 5) + $(echo 10) ))  # Inefficient

# Error: Globbing issues
rm -rf $HOME/*  # Dangerous unquoted glob

# Error: Exit code not preserved
function wrapper() {
    some_command
    echo "Done"  # This changes $?
}

# Error: Using deprecated syntax
while IFS='' read line; do  # Missing -r flag
    echo "$line"
done < file.txt

# Error: Not quoting command substitution
FILES=$(ls *.txt)  # Should quote and not parse ls

# Error: Using eval unnecessarily
CMD="echo hello"
eval $CMD  # Dangerous

# Error: Not using local in function
function set_vars() {
    VAR1="value"  # Should be local
    VAR2="value"  # Should be local
}

# Error: Semicolon spacing
if true;then  # Missing space after semicolon
    echo "true"
fi

# Error: Brace expansion without quotes
mkdir {test1,test2,test 3}  # Space in test 3 will cause issues

# Error: Here document without proper delimiter
cat << EOF
This is a here document
But EOF has leading spaces below
  EOF

# Error: Case statement formatting
case $VAR in
pattern1) echo "1";;  # Should be on separate lines
pattern2) echo "2";;
esac

# Error: Nested quotes issues
echo "This is "quoted" text"  # Incorrect nesting

# Error: Using source instead of .
source /etc/profile  # Prefer . for POSIX compliance

# Error: Not checking if file exists before sourcing
. /maybe/missing/file.sh

# Error: Pipeline failures not detected
set -e
false | echo "This will succeed"  # Pipeline doesn't fail with set -e alone

# Error: Race condition in file operations
if [ ! -f /tmp/file ]; then
    touch /tmp/file  # Race condition between check and creation
fi

# Error: Using kill -9 as first resort
kill -9 $PID  # Should try SIGTERM first

# Error: Not validating user input
read -p "Enter filename: " filename
rm $filename  # Dangerous! No validation or quotes

# Error: Incorrect arithmetic operations
let "result = 5 + 5"  # Prefer (( )) or $(( ))

# Error: Loop variable not local
for i in 1 2 3; do
    for i in a b c; do  # Inner loop reuses same variable
        echo $i
    done
done

# Error: Comparing strings with -eq
if [ "$STR" -eq "test" ]; then  # -eq is for numbers
    echo "Equal"
fi

# Error: Not preserving field splitting
IFS=:
set -- $PATH  # Should quote or use array

# Error: Missing proper error handling
#!/bin/bash
# Should have: set -euo pipefail

echo "Script completed with errors!"
