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
###


@create[]
    $self.security[^Security::create[]]
    $self.session[^Session::create[]]
    $self.githubApi[^GithubApi::create[]]
###


@logoutAction[][result]
    $self.session.userID[]
    ^self.redirect[/login]
###


@loginAction[][result]
    ^if(^self.security.isGranted[]){
        ^self.redirect[/package]
    }{
        $doc[^xdoc::create[root]]
        $root[^doc.selectSingle[//root]]
        $githubNode[^doc.createElement[github-client-id]]
        $t[^githubNode.appendChild[^doc.createTextNode[$MAIN:GithubClientId]]]
        $t[^root.appendChild[$githubNode]]

        ^if(!def $form:fields.code){
            $transformedDoc[^doc.transform[../data/templates/user/login.xsl]]
        }{
            $data[^githubApi.getAccessToken[$form:fields.code]]

            ^if(def $data.error){
                $error[^doc.createElement[error]]
                $text[^doc.createTextNode[$data.error_description]]
                $t[^error.appendChild[$text]]
                $t[^root.appendChild[$error]]

                $transformedDoc[^doc.transform[../data/templates/auth.xsl]]
            }{
                $access_token[$data.access_token]
                $self.githubApi.access_token[$access_token]
                $githubUserData[^self.githubApi.getUser[]]

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


        $result[^if(!def $transformedDoc){}{^transformedDoc.string[$.method[html]]}]
    }
###
