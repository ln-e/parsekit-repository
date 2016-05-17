# Created by IntelliJ IDEA.
# User: ibodnar
# Date: 08.05.16
# Time: 19:01
# To change this template use File | Settings | File Templates.

@CLASS
Security

@OPTIONS
locals

@auto[]
###


@create[session]
    $self.session[$session]
    $self.user[]
###


@getUser[][result]
    ^if(!def $self.user){
        $userID[$self.session.userID]

        ^if(def $userID){
            ^connect[$MAIN:SQL.connect-string]{
                $table[^table::sql{
                    SELECT * FROM user
                    WHERE user.id = $userID
                }]
            }
            $self.user[$table.fields]
        }
    }

    $result[$self.user]
###


@isGranted[][result]
    $user[^self.getUser[]]
    $result(def $user)
###
