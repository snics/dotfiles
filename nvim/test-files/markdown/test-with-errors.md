# Markdown Test File with Errors
## Missing Blank Line Before Heading
This text doesn't have a blank line before the heading above.
### Inconsistent Heading Levels
##### Skipped heading level (went from h3 to h5)

# Multiple H1 Headers
# This is wrong - should only have one H1

## Trailing Punctuation in Heading!!!
### Another Bad Heading?

##No Space After Hash
###Another One Without Space

## Trailing Spaces at End of Lines  
This line has trailing spaces at the end.    
Another line with trailing spaces.   

Inconsistent Line Breaks
This paragraph doesn't have proper spacing.
This line should be separated by blank line or be on same line.

## Lists with Issues

* Inconsistent bullet markers
- Using different marker
+ Yet another marker
* Back to asterisk

1. Numbered list
1. Using same number
1. Still using 1
1. Should increment

 * Indented list item with space before marker
  - Inconsistent indentation
   + Too many spaces

* Missing blank line before list
1. Switching list types without blank line
* Back to bullets

Paragraph without blank line after list
* List item
Text immediately after without blank line

## Long Lines

This is an extremely long line that exceeds the typical 80 or 100 character limit that many markdown linters enforce by default and should be wrapped to multiple lines for better readability.

## Code Blocks

```
Code block without language specification
```

    Indented code block (less preferred than fenced)
    with multiple lines

`inline code with ` backtick inside`

```javascript
// Code block without blank lines around it
```
No blank line after code block

## Links and Images

[Empty Link Text]()
[](https://example.com)
[Link with space in URL](https://example .com)
[Broken reference link][broken]
[Case insensitive LINK][REFERENCE]

<https://example.com> (bare URL not in angle brackets)
https://example.com

![](image.jpg) Missing alt text
![Image](image.jpg "title" ) Extra space before closing paren

[reference]: https://example.com
[Reference]: https://example.com  Duplicate reference (different case)

## Tables

|Header 1|Header 2|Header 3|
|---|---|---|
|Cell 1|Cell 2|Cell 3|
No blank lines around table

| Inconsistent | Spacing|In|Headers |
| --- | --- | --- | --- |
| Cell | Cell | Cell | Cell |

|Missing|Separator|
|Cell|Cell|

## HTML in Markdown

<div>Using HTML block elements</div>
<span>Inline HTML</span>
<br> Using break tags

<h2>HTML heading instead of Markdown</h2>

## Emphasis and Strong

*inconsistent emphasis* and _emphasis markers_
**inconsistent strong** and __strong markers__
***mixed* emphasis** markers

This is*not*properly spaced emphasis
This is**not**properly spaced strong

## Blockquotes

>Missing space after angle bracket
> Proper blockquote

> Blockquote with
multiple lines not properly marked

> > Nested blockquote
> Without proper structure

## Horizontal Rules

***
___
---
*** Using inconsistent rule styles

## Special Characters

Using smart quotes: "curly quotes" and 'single quotes'
Using em dash — instead of --
Using ellipsis… instead of ...

## Blank Lines

Too many blank lines below:



Only one blank line should be used

## Line Endings

This file might have inconsistent line endings (CRLF vs LF).
Check with your linter for line ending issues.

## Tabs vs Spaces

	This line starts with a tab
  This line starts with spaces
	  Mixed tabs and spaces

## Ordered List Issues

1) Using parenthesis instead of period
2) Another one

1. Starting with 1
3. Jumping to 3
5. Then to 5

## Definition Lists (not standard Markdown)

Term
: Definition using colon (not supported everywhere)

## Missing Final Newline

This file doesn't end with a newline
