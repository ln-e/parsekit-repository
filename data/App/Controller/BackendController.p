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
        $result[]
        $doc[^xdoc::create[root]]
        $root[^doc.selectSingle[//root]]
        $usersNode[^doc.createElement[users]]
        $t[^root.appendChild[$usersNode]]

        ^connect[$MAIN:SQL.connect-string]{
            $users[^hash::sql{
                SELECT u.id, u.* FROM user as u
            }[$.limit(10)]]
        }

        ^users.foreach[key;value]{
            $userNode[^doc.createElement[user]]
            $t[^usersNode.appendChild[$userNode]]
            ^value.foreach[k;v]{
                $el[^doc.createElement[$k]]
                $el.nodeValue[$v]
                $t[^userNode.appendChild[$el]]
            }
        }

        $transformedDoc[^doc.transform[../data/templates/backend/user/index.xsl]]
        $result[^if(!def $transformedDoc){}{^transformedDoc.string[$.method[html]]}]
    }
###
