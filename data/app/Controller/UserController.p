# Created by IntelliJ IDEA.
# User: ibodnar
# Date: 08.05.16
# Time: 12:19
# To change this template use File | Settings | File Templates.

@CLASS
UserController

@OPTIONS
locals

@BASE
BaseController

@auto[]
    $self.security[^Security::create[]]
    $self.session[^Session::create[]]
###


@create[]
###


@loginAction[][result]
    ^if(^self.security.isGranted[]){
        ^self.redirect[/package]
    }{
        $doc[^xdoc::create[root]]
        $root[^doc.selectSingle[//root]]

        ^if(!def $form:fields.code){
            $transformedDoc[^doc.transform[../data/templates/auth.xsl]]
        }{
            $file[^curl:load[
                $.url[https://github.com/login/oauth/access_token]
                $.useragent[parsekit]
                $.timeout(10)
                $.ssl_verifypeer(0)
                $.post(1)
                $.httpheader[
                    $.accept[application/json]
                ]
                $.postfields[client_id=e0a9aa67dbb28d792909&client_secret=899d80953ed8e459cd65424fc7d158bc4db3f58f&code=$form:fields.code]
            ]]

            $data[^json:parse[^taint[as-is][$file.text]]]

            ^if(def $data.error){
                $error[^doc.createElement[error]]
                $text[^doc.createTextNode[$data.error_description]]
                $t[^error.appendChild[$text]]
                $t[^root.appendChild[$error]]

                $transformedDoc[^doc.transform[../data/templates/auth.xsl]]
            }{
                $access_token[$data.access_token]
                $file[^curl:load[
                    $.url[https://api.github.com/user]
                    $.useragent[parsekit]
                    $.timeout(10)
                    $.ssl_verifypeer(0)
                    $.httpheader[
                        $.Authorization[token $access_token]
                    ]
                ]]

                $githubUserData[^json:parse[^taint[as-is][$file.text]]]

                ^connect[$MAIN:SQL.connect-string]{
                    $table[^table::sql{
                        SELECT * FROM user
                        WHERE user.github_id = $githubUserData.id
                    }]

                    ^if(!def $table){
                        $t[^void:sql{
                            INSERT INTO user(email, github_id, github_token)
                            VALUES('$githubUserData.email', $githubUserData.id, '$access_token')
                        }]
                        $id[^int:sql{SELECT last_insert_id()}]
                        $self.session.userID[$id]
                    }{
                        $t[^void:sql{
                            UPDATE user SET github_token = '$access_token'
                            WHERE user.id = $table.id
                        }]
                        $self.session.userID[$table.id]
                    }
                }

                ^self.redirect[/package]
            }
        }


       ^if(def $transformedDoc){
            $result[^transformedDoc.string[
                $.method[html]
            ]]
       }{
            $result[]
       }

    }
###
