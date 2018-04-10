"""
    generate_tokenizer_from_sed(sed_script_path)

This returns Julia code, that is the translation of a simple sed script
for tokenizing.
This doesn't fully cover all the functionality of sed,
but it covers enough for many purposes.
"""
function generate_tokenizer_from_sed(sed_script)::Expr
    code = quote
        ss = input
    end
    for src_line in eachline(sed_script)
        src_line=strip(src_line)
        length(src_line)==0 && continue # skip blanks
        src_line[1]=='#' && continue # skip comments

        #sed lines are `<op><sep><pattern><sep><replacement><sep>flags`
        seperator = src_line[2]
        op, pattern, replacement, flags = split(src_line, seperator)
        @assert(op=="s") #substitute
        @assert(flags=="g" || flags=="", "Unsupported flags: $flags") #substitute
        push!(code.args, :(
            ss=replace(ss,
                       Regex($pattern),
                       Base.SubstitutionString($replacement))
        ))
    end
    push!(code.args, :(split(ss)))
    code
end


"""
    penn_tokenize(input::AbstractString)

"... to produce Penn Treebank tokenization on arbitrary raw text.
Yeah, sure" quote Robert MacIntyre



Tokenisation does a number of things like seperate out contractions:
"shouldn't" becomes ["should", "n't"]
Most other punctuation becomes &'s.
Exception is periods which are not touched.
The input should be a single sentence;
but it will likely be relatively fine if it isn't.
Depends exactly what you want it for.

If you want to mess with exactly what it does it is actually really easy.
copy the penn.sed file from this repo, modify it to your hearts content.
There are some lines you can uncomment out.
You can generate a new tokenizer using:

```
@generated function custom_tokenizer(input::AbstractString)
    generate_tokenizer_from_sed(joinpath(@__DIR__, "custom.sed"))
end
```
"""
@generated function penn_tokenize(input::AbstractString)
    generate_tokenizer_from_sed(joinpath(@__DIR__, "penn.sed"))
end



"""
    improved_penn_tokenize(input::AbstractString)

This is a port of NLTK's modified Penn Tokeniser.
The only difference to the original is how it handles punctuation.
Punctuation is preserved as its own token.
This includes periods which will be stripped from words.

The tokeniser still seperates out contractions:
"shouldn't" becomes ["should", "n't"]

The input should be a single sentence;
but again it will likely be relatively fine if it isn't.
Depends exactly what you want it for.
"""
@generated function improved_penn_tokenize(input::AbstractString)
    generate_tokenizer_from_sed(joinpath(@__DIR__, "improved_penn.sed"))
end
