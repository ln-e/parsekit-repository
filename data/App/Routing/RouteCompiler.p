# Created by IntelliJ IDEA.
# User: ibodnar
# Date: 08.05.16
# Time: 10:57
# To change this template use File | Settings | File Templates.

@CLASS
RouteCompiler

@OPTIONS
locals

@auto[]

#   This string defines the characters that are automatically considered separators in front of
#   optional placeholders (with default and no static text following). Such a single separator
#   can be left out together with the optional placeholder from matching and generating URLs.
    $self.SEPARATORS[/,^;.:-_~+*=@|]

###


@create[]
###


@compile[route][result]
    $hostVariables[^hash::create[]]
    $variables[^hash::create[]]
    $hostRegex[]
    $hostTokens[^hash::create[]]
    $host[$route.host]

    ^if('' ne $host){
        $tempResult[^self.compilePattern[$route;$host](true)]
        $hostVariables[$tempResult.variables]
        $variables[$hostVariables]
        $hostTokens[$tempResult.tokens]
        $hostRegex[$tempResult.regex]
    }
    $path[$route.path]
    $tempResult[^self.compilePattern[$route;$path](false)]
    $staticPrefix[$tempResult.staticPrefix]
    $pathVariables[$tempResult.variables]
    ^variables.add[$pathVariables]
    $tokens[$tempResult.tokens]
    $regex[$tempResult.regex]

    $result[^CompiledRoute::create[$staticPrefix;$regex;$tokens;$pathVariables;$hostRegex;$hostTokens;$hostVariables;$variables]]
###


@compilePattern[route;pattern;isHost][result]
    $tokens[^hash::create[]]
    $variables[^hash::create[]]
    $pos(0)
    $defaultSeparator[^if($isHost){.}{/}]

    $matches[^pattern.match[({(\w+)})][gi']]

    ^matches.menu{
        $varName[$matches.1]
        $precedingText[^pattern.mid($pos;^matches.prematch.length[] - $pos)]
        $pos(^matches.prematch.length[] + ^matches.match.length[])
        $precedingChar[^matches.prematch.mid(0;1)]
        $isSeparator(^self.SEPARATORS.pos[$precedingChar])

        ^if(^variables.contains[$varName]){
            ^throw[LogicException;;Route "$pattern" cannot reference variable name "$varName" more than once.]
        }

        ^if($isSeparator && ^precedingText.length[] > 1){
            $tokens.[^tokens._count[]][
                $.0[text]
                $.1[^precedingText.mid(0;^precedingText.length[]-1)]
            ]
        }(!$isSeparator && ^precedingText.length[] > 0){
            $tokens.[^tokens._count[]][
                $.0[text]
                $.1[$precedingText]
            ]
        }

        $regexp[$route.requirements.$varName]

        ^if(!def $regexp){
            $nextSeparator[^self.findNextSeparator[$matches.postmatch]]
#           All except separators regex
            $regexp[^[^^^taint[regex][$defaultSeparator]^taint[regex][^if($defaultSeparator ne $nextSeparator){$nextSeparator}{}]^]+]
        }

        $tokens.[^tokens._count[]][
            $.0[variable]
            $.1[^if($isSeparator){$precedingChar}{}]
            $.2[$regexp]
            $.3[$varName]
        ]
        $variables.[^variables.count[]][$varName]
    }

    ^if($pos < ^pattern.length[]){
        $tokens.[^tokens._count[]][
            $.0[text]
            $.1[^pattern.mid($pos)]
        ]
    }

    $firstOptional(inf)
    ^if(!$isHost){
        $i(^tokens._count[])
        ^while($i >= 0){
            ^i.dec[]
            $token[^tokens._at($i)]
            ^if('variable' eq $token.0 && ^route.hasDefault[$token.3]){
                $firstOptional[$i]
            }{
                ^break[]
            }
        }
    }

    $regexp[]

    $i(0)
    $nbToken(^tokens._count[])
    ^while($i<$nbToken){
        $regexp[$regexp^self.computeRegexp[$tokens;$i;$firstOptional]]
        ^i.inc[]
    }

    $result[
        $.staticPrefix[^if($tokens.0.0 eq text){$tokens.0.1}{}]
        $.regex[^^$regexp^$]
        $.regexModifiers[s^if($isHost){i}{}]
        $.tokens[array_reverse($tokens)]
        $.variables[$variables]
    ]
###


@findNextSeparator[pattern][result]
    ^if(!def $pattern || '' eq $pattern){
        $result[]
    }{
#       remove all placeholders
        $pattern[^pattern.match[(\{\w+\})][gi]{}]
        $symbol[^pattern.mid(0;1)]
        $result[^if(^self.SEPARATORS.pos[$symbol] >= 0){$symbol}{}]
    }
###


@computeRegexp[tokens;index;firstOptional][result]
    $token[$tokens.$index]
    ^if('text' eq $token.0){
        $result[^taint[regex][$token.1]]
    }{
        ^if(0 == $index && 0 == $firstOptional){
#           When the only token is an optional variable token, the separator is required
            $result[^taint[regex][$token.1^(?P<$token.3>$token.2)?]]
        }{
            $regexp[^taint[regex][$token.1^(?P<$token.3>$token.2)]]

            ^if($index >= $firstOptional){
#               Enclose each optional token in a subpattern to make it optional.
#               "?:" means it is non-capturing, i.e. the portion of the subject string that
#               matched the optional subpattern is not passed back.
                $regexp[(?:$regexp]
                $nbTokens[^tokens.count[]]
                ^if($nbTokens - 1 == $index){
#                   Close the optional subpatterns
                    $regexp[$regexp^self.repeatString[)?;$nbTokens - $firstOptional - (^if($firstOptional == 0){1}{0})]]
                }
            }
            $result[$regexp]
        }
    }
###


@repeatString[str;times][result]
    ^for[i](0;$times){$result[${result}$str]}
###