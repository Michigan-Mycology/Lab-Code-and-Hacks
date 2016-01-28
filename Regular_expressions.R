###### PART1: String functions related to regular expression
    txt <- c("The", "R", "Foundation", "for Statistical Computing");
    
    # Type1: identify match to a pattern
    grep("Found", txt, value=F);
    grepl("found", txt, ignore.case = T);
    
    # Type2: extract match to a pattern
    grep("Found", txt, value=T);

    # Type3: replace a pattern
    gsub("a", "E", "abc abc")
    sub("a", "E", "abc abc")

    # Type4: split a string using a patter
    strsplit(x="abcd",split="b");

###### PART2: Regular expression syntax
    #1. Escape sequences
    # \': single quote. You don’t need to escape single quote inside a double-quoted string, so we can also use "'" in the previous example.
    # \": double quote. Similarly, double quotes can be used inside a single-quoted string, i.e. '"'.
    # \n: newline.
    # \t: tab character
    cat("\"a\nb\tc\'")

    #2 Quantifiers
    # *: matches at least 0 times.
    # +: matches at least 1 times.
    # ?: matches at most 1 times.
    # {n}: matches exactly n times.
    # {n,}: matches at least n times.
    # {n,m}: matches between n and m times.
    
    strings <- c("a", "ab", "acb", "accb", "acccb", "accccb")
    grep("ac*b", strings, value = TRUE)
    grep("ac+b", strings, value = TRUE)
    grep("ac?b", strings, value = TRUE)
    grep("ac{2}b", strings, value = TRUE)
    grep("ac{2,}b", strings, value = TRUE)
    grep("ac{2,3}b", strings, value = TRUE)

    # 3. Position of pattern within string
    strings <- c("abcd", "cdab", "cabd");
    grep("^ab", strings, value = TRUE);
    grep("ab$", strings, value = TRUE)

    # 4. Operators
    # .: matches any single character
    # [...]: a character list, matches any one of the characters inside the square brackets
    # [^...]: an inverted character list, similar to [...], 
          #   but matches any characters except those inside the square brackets.
    # |: an “or” operator, matches patterns on either side of the |.
    # (...): grouping in regular expressions. This allows you to retrieve the bits that matched various parts of your regular expression so you can alter them or use them for building up a new string. Each group can than be refer using \\N, with N being the No. of (...) used. This is called
    strings <- c("^ab", "ab", "abc", "abd", "abe");
    grep("ab.", strings, value = TRUE)
    grep("ab[c-e]", strings, value = TRUE)
    grep("ab[^c]", strings, value = TRUE)
    grep("^ab", strings, value = TRUE)
    grep("abc|abd", strings, value = TRUE)
    gsub("(ab)", "\\1\\1", strings)


# PART3: Exercises
    
    #1. find the indices of strings ending with "at"
    # HINT: at
    array <- c("hat", "cat", "at home", "hate");
    result <- ();
   
    
    #2. double all 'a' or 'b's in the following string
    #   add a hyphen after each 'a' or 'b's,
    #   ignore case
    # HINT: gsub
    
    string <- "abc ABC";
    result <- "a_a_b_b_c A_A_B_B_C"
    ## Double all 'a' or 'b's;  "\" must be escaped, i.e., 'doubled'
    
    #3. Make up a question for your neighbor and then answer their question
    
    
    
    
    
    
    
    
    
    
#########################
# ANSWER FOR EXERCISES
#########################

#   EX1
    grep("at$", array, value = FALSE)

#   EX2
    a|b
    gsub("([ab])", "\\1_\\1_", string, ignore.case=T)

# Reference http://stat545-ubc.github.io/block022_regular-expression.html#general-modes-for-patterns
    
