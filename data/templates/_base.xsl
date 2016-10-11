<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output indent="no" omit-xml-declaration="yes" method="html" />

    <xsl:template match="/">
        <html>
            <head>
                <meta name="viewport" content="width=device-width, initial-scale=1" />
                <title>parsekit.ru - package manager</title>
                <xsl:apply-templates select="." mode="scripts" />
            </head>
            <body>
                <xsl:apply-templates select="." mode="body" />
            </body>
        </html>
    </xsl:template>


    <xsl:template match="*" mode="scripts">
        <link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"/>
        <link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css" />
        <link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/font-awesome/4.6.3/css/font-awesome.min.css" />
        <link rel="stylesheet" href="/style.css" />
        <script src="//maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"/>
    </xsl:template>


    <xsl:template match="*" mode="body">
        <xsl:call-template name="nav"/>

        <div class="container">
            <div class="page-header">
                <h1><xsl:call-template name="page_title"/></h1>
                <p class="lead"><xsl:call-template name="page_title_description"/></p>
            </div>

            <xsl:call-template name="body_inner"/>

        </div>
    </xsl:template>


    <xsl:template name="page_title"/>
    <xsl:template name="page_title_description"/>

    <xsl:template name="body_inner"/>


    <xsl:template name="nav">
        <nav class="navbar navbar-inverse navbar-fixed-top">
            <div class="container">
                <div class="navbar-header">
                    <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
                        <span class="sr-only">Toggle navigation</span>
                        <span class="icon-bar"/>
                        <span class="icon-bar"/>
                        <span class="icon-bar"/>
                    </button>
                    <a class="navbar-brand" href="/">Parsekit</a>
                </div>
                <div id="navbar" class="navbar-collapse collapse" aria-expanded="false" style="height: 1px;">
                    <ul class="nav navbar-nav">
                        <li><a href="/download">Downloads</a></li>
                        <li><a href="/package">My packages</a></li>
                        <li><a href="/login">Login</a></li>
                        <li><a href="/logout">Logout</a></li>
                    </ul>
                </div><!--/.nav-collapse -->
            </div>
        </nav>
    </xsl:template>


</xsl:stylesheet>