# Created by IntelliJ IDEA.
# User: ibodnar
# Date: 08.05.16
# Time: 20:05
# To change this template use File | Settings | File Templates.

@CLASS
PackagesController

@OPTIONS
locals

@BASE
BaseController

@auto[]
###

@create[]
    $self.security[^Security::create[]]
    $self.githubApi[^GithubApi::create[]]
###

@allAction[]
    $doc[^xdoc::create[root]]
    $root[^doc.selectSingle[//root]]
    $packagesNode[^doc.createElement[packages]]
    $t[^root.appendChild[$packagesNode]]

    ^connect[$MAIN:SQL.connect-string]{
        $packages[^hash::sql{
            SELECT p.* FROM package as p
        }[$.limit(10)]]
    }

    ^packages.foreach[key;value]{
        $packageNode[^doc.createElement[package]]
        $t[^packagesNode.appendChild[$packageNode]]
        ^value.foreach[k;v]{
            $el[^doc.createElement[$k]]
            $el.nodeValue[$v]
            $t[^packageNode.appendChild[$el]]
        }
    }

    $transformedDoc[^doc.transform[../data/templates/packages/all.xsl]]
    $result[^if(!def $transformedDoc){}{^transformedDoc.string[$.method[html]]}]
###


@listAction[]
    ^if(!^self.security.isGranted[]){
        ^self.redirect[/login]
    }{
        $doc[^xdoc::create[root]]
        $root[^doc.selectSingle[//root]]
        $packagesNode[^doc.createElement[packages]]
        $t[^root.appendChild[$packagesNode]]

        $user[^self.security.getUser[]]
        ^connect[$MAIN:SQL.connect-string]{
            $packages[^hash::sql{
                SELECT p.id, p.* FROM package as p
                LEFT JOIN package_user as pu ON p.id = pu.package_id
                WHERE pu.user_id = $user.id
            }]
        }


        ^packages.foreach[key;value]{
            $packageNode[^doc.createElement[package]]
            $t[^packagesNode.appendChild[$packageNode]]
            ^value.foreach[k;v]{
                $el[^doc.createElement[$k]]
                $el.nodeValue[$v]
                $t[^packageNode.appendChild[$el]]
            }
        }

        $transformedDoc[^doc.transform[../data/templates/packages/show.xsl]]
        $result[^if(!def $transformedDoc){}{^transformedDoc.string[$.method[html]]}]
    }
###


@addAction[]
    ^if(!^self.security.isGranted[]){
        ^self.redirect[/login]
    }{
        $user[^self.security.getUser[]]
        $packageName[^taint[as-is][$form:fields.package]]
        $hookData[^self.githubApi.createRepoHook[$packageName]]
        $parsekit[^self.githubApi.getParsekitFile[$packageName;master]]

        ^if(!def $hookData.id){
            ^throw[CouldNotCreateHookException;;Hook creation failed: ^json:string[$hookData]]
        }

        $readmeFile[^self.githubApi.getSourceFile[$packageName;master;README.md]]

        ^connect[$MAIN:SQL.connect-string]{
            $packageName[^if(!def $parsekit.name || ^parsekit.name.trim[] eq ''){$packageName}{$parsekit.name}]
            $r[^void:sql{
                INSERT INTO package(hook_id,name,target_dir,type,description,keywords,readme)
                VALUES(
                    $hookData.id,
                    '$packageName',
                    '$packageName',
                    '$parsekit.type',
                    '$parsekit.description',
                    '^if($parsekit.keywords is hash){^parsekit.keywords.foreach[i;keyword]{$keyword}[,]}{ }',
                    '$readmeFile.text'
                )
            }]

            $packageId[^int:sql{SELECT last_insert_id()}]

            $r[^void:sql{
                INSERT INTO package_user(user_id,package_id)
                VALUES($user.id, $packageId)
            }]
        }

        ^self.githubApi.ping[$packageName;$hookData.id]

        ^self.redirect[/package]
    }
###
