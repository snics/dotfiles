// =============================================================================
// JavaScript Test File with ESLint Errors
// Tests for eslint_d
// =============================================================================

// Error: Missing semicolons (if semi rule is enabled)
const noSemi = "missing semicolon"
let anotherNoSemi = 123

// Error: Var instead of let/const
var oldStyle = "should use let or const"
var mutable = 1

// Error: Unused variables
const unusedVariable = "never used"
let anotherUnused = 123
function unusedFunction() {
  return "never called"
}

// Error: Undefined variables
console.log(undefinedVariable)
result = someUndefinedFunction()

// Error: No return in array methods
const numbers = [1, 2, 3]
numbers.map(n => {
  n * 2  // Missing return
})

// Error: Console statements (often forbidden in production)
console.log("Debug output")
console.error("Error output")
console.warn("Warning")

// Error: Debugger statement
debugger

// Error: Alert/confirm/prompt (browser globals)
alert("Hello")
confirm("Are you sure?")
const input = prompt("Enter value")

// Error: == instead of ===
if (value == "test") {
  // Should use ===
}
if (value != null) {
  // Should use !==
}

// Error: Eval usage
eval("console.log('dangerous')")
const func = new Function("return 1")

// Error: With statement
with (obj) {
  // With statement is forbidden
}

// Error: Implied eval
setTimeout("alert('Hi')", 1000)
setInterval("update()", 1000)

// Error: Missing radix in parseInt
const num = parseInt("10")  // Should specify radix
const binary = parseInt("1010")  // Ambiguous without radix

// Error: Useless escape
const escaped = "Useless \e\s\c\a\p\e"
const regex = /\-/  // Dash doesn't need escape

// Error: No-shadow (variable shadowing)
const shadow = "outer"
function testShadow() {
  const shadow = "inner"  // Shadows outer variable
  return shadow
}

// Error: Camelcase violation
const snake_case = "should be camelCase"
const PascalCaseVar = "should start lowercase"
function Wrong_Case() {}

// Error: Max line length exceeded
const veryLongLine = "This is an extremely long line that exceeds the maximum line length that ESLint typically enforces which is usually 80 or 100 characters"

// Error: Complexity too high
function tooComplex(a, b, c, d, e) {
  if (a) {
    if (b) {
      if (c) {
        if (d) {
          if (e) {
            return "too nested"
          }
        }
      }
    }
  }
  return "default"
}

// Error: Unused function parameters
function hasUnusedParams(used, unused, alsoUnused) {
  return used
}

// Error: Prefer const
let neverReassigned = "should be const"
let alsoNeverChanged = 123

// Error: No constant condition
if (true) {
  // Always true
}
while (false) {
  // Never executes
}

// Error: Unreachable code
function unreachable() {
  return true
  console.log("Never reached")  // Unreachable
  const dead = "code"
}

// Error: No empty blocks
if (condition) {
  // Empty block
}
try {
  // Empty try
} catch (e) {
  // Empty catch
}

// Error: Missing braces
if (condition)
  doSomething()  // Should have braces

for (let i = 0; i < 10; i++)
  console.log(i)  // Should have braces

// Error: No-unsafe-negation
if (!key in object) {
  // Should be !(key in object)
}

// Error: Valid typeof
if (typeof value === "strnig") {  // Typo
  // ...
}
if (typeof value == "undefined") {  // Should use === and compare to undefined
  // ...
}

// Error: Duplicate keys in object
const obj = {
  key: "value1",
  key: "value2",  // Duplicate key
  other: "value"
}

// Error: No-dupe-args
function duplicateParams(a, b, a) {  // Duplicate parameter
  return a + b
}

// Error: Switch fall-through without comment
switch (value) {
  case 1:
    doSomething()
    // Missing break
  case 2:
    doSomethingElse()
    break
  default:
    doDefault()
}

// Error: Default case not last
switch (value) {
  default:
    doDefault()
    break
  case 1:
    doSomething()
    break
}

// Error: Yoda conditions
if ("red" === color) {  // Yoda condition
  // ...
}
if (5 == value) {  // Yoda condition
  // ...
}

// Error: Trailing comma (depending on rules)
const array = [1, 2, 3,]  // Trailing comma
const object = {
  a: 1,
  b: 2,
}  // Trailing comma

// Error: Missing space before function parentheses
function noSpace(){  // Missing space
  return true
}
const arrow = ()=>{  // Missing spaces
  return true
}

// Error: Inconsistent spacing
const spacing = {a:1,b:2,c:3}  // No spaces
const inconsistent = { a: 1, b :2, c : 3 }  // Inconsistent

// Error: Multiple empty lines


// Too many empty lines

// Error: Trailing spaces at end of line  
const trailing = "has trailing spaces"   

// Error: Mixed spaces and tabs
function mixed() {
	const tab = "indented with tab"
  const spaces = "indented with spaces"
}

// Error: No-plusplus
for (let i = 0; i < 10; i++) {  // Using ++
  count++  // Using ++
}

// Error: Prefer template literals
const str = "Hello " + name + "!"  // Should use template literal
const multi = "Line 1\n" +
              "Line 2\n" +
              "Line 3"

// Error: Prefer arrow functions
array.map(function(item) {  // Should use arrow function
  return item * 2
})

// Error: No nested ternary
const nested = a ? b : c ? d : e  // Nested ternary

// Error: No unneeded ternary
const bool = condition ? true : false  // Redundant

// Error: Prefer destructuring
const props = obj.props  // Could destructure
const first = array[0]  // Could destructure
const second = array[1]

// Error: No magic numbers
const timeout = 3600000  // What does this number mean?
if (value > 86400) {  // Magic number
  // ...
}

// Error: No multiple assignments
let a, b, c
a = b = c = 1  // Multiple assignments

// Error: Require await in async function
async function noAwait() {
  return Promise.resolve(1)  // No await used
}

// Error: No return await
async function returnAwait() {
  return await Promise.resolve(1)  // Unnecessary await
}

// Error: No async promise executor
new Promise(async (resolve, reject) => {  // Async executor
  resolve(1)
})

// Error: Array callback return
[1, 2, 3].forEach(n => {
  return n * 2  // forEach doesn't use return
})

// Error: No implied eval in dynamic imports
import(userInput)  // Dynamic import with user input

// Error: Prefer rest params
function useArguments() {
  console.log(arguments)  // Should use rest params
}

// Error: No useless constructor
class UselessConstructor {
  constructor() {
    // Does nothing, just calls super
  }
}

// Error: Getter without setter
const getterOnly = {
  get value() {
    return this._value
  }
  // Missing setter
}

// Error: No label var
label:  // Labels are often discouraged
for (let i = 0; i < 10; i++) {
  break label
}

// Error: No lonely if
if (condition) {
  doSomething()
} else {
  if (otherCondition) {  // Should be else if
    doOther()
  }
}

// Error: Radix issues
parseInt("10", 2)  // Valid but might be confusing
parseInt("08")  // Octal issue without radix

// Error: No sequences
const seq = (a = 1, b = 2, a + b)  // Sequence expression

// Error: Void operator
const nothing = void 0  // Using void operator

// Error: No new wrappers
const str = new String("text")  // Wrapper object
const num = new Number(123)
const bool = new Boolean(true)

// Error: No-extend-native
Array.prototype.customMethod = function() {}  // Extending native

// Error: Assignment in condition
if (result = someFunction()) {  // Assignment in condition
  // ...
}

// Error: No bitwise
const bit = a & b  // Bitwise operation
const shift = c << 2  // Bit shift

// Error: Comma dangle inconsistency
const trailingComma = {
  a: 1,
  b: 2
}
const noTrailingComma = {
  c: 3,
  d: 4,  // Inconsistent
}

// Error: Missing JSDoc
function undocumented(param) {  // Missing JSDoc comment
  return param * 2
}

// Error: Invalid JSDoc
/**
 * @param {string} name
 * @returns {number}  // Wrong return type
 */
function documented(name) {
  return name  // Returns string, not number
}

// Error: No-undefined
if (value === undefined) {  // Comparing to undefined
  // ...
}

// Error: Init declarations
let uninitialized  // Not initialized
const mustInit = undefined  // Explicitly undefined

// Error: No delete
delete obj.property  // Using delete

// Error: No octal
const octal = 0777  // Octal literal

// Error: Confusing arrow function
const confusing = a => b => c => a + b + c  // Too many arrows

// Error: No script URL
const link = "javascript:void(0)"  // JavaScript URL

// Error: Missing 'use strict' (if required)
// No 'use strict' at top of file

// Error: File doesn't end with newline
