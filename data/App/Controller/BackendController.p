# Created by IntelliJ IDEA.
# User: ibodnar
# Date: 01.05.16
# Time: 11:25
# To change this template use File | Settings | File Templates.

@CLASS
BackendController

@OPTIONS
locals

@BASE
BaseController

@auto[]
###

@create[]
    $self.security[$DI:security]
###


@userIndexAction[]
    ^if(!^self.security.isGranted[ROLE_ADMIN]){
        ^self.redirect[/login]
    }{
        ^connect[$MAIN:SQL.connect-string]{
            $users[^hash::sql{
                SELECT u.id, u.* FROM user as u
            }[$.limit(10)]]
        }

        $data[
            $.users[$users]
        ]

        $result[^self.render[$data;../data/templates/backend/user/index.xsl]]
    }
###
