<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:template match="/">
        <html>
            <head>
                <title>parsekit.ru - package manager</title>
                <xsl:apply-templates select="." mode="scripts" />
            </head>
            <body>
                <xsl:apply-templates select="." mode="body" />
            </body>
        </html>
    </xsl:template>


    <xsl:template match="*" mode="scripts">
        <script src="//code.jquery.com/jquery-1.12.3.min.js"/>
        <link rel="stylesheet" href="//cdnjs.cloudflare.com/ajax/libs/uikit/2.26.2/css/uikit.min.css" />
        <link rel="stylesheet" href="//cdnjs.cloudflare.com/ajax/libs/uikit/2.26.2/css/uikit.almost-flat.css" />
        <script src="//cdnjs.cloudflare.com/ajax/libs/uikit/2.26.2/js/uikit.min.js"/>
    </xsl:template>


    <xsl:template match="*" mode="body">
        <div class="uk-container uk-container-center uk-margin-top uk-margin-large-bottom">

            <xsl:call-template name="nav"/>

            <div class="uk-grid" data-uk-grid-margin="">
                <div class="uk-width-1-1 uk-row-first">
                    <h1 class="uk-heading-large"><xsl:call-template name="page_title"/></h1>
                    <p class="uk-text-large"><xsl:call-template name="page_title_description"/></p>
                </div>
            </div>

            <xsl:call-template name="body_inner"/>

        </div>
    </xsl:template>


    <xsl:template name="page_title"/>
    <xsl:template name="page_title_description"/>

    <xsl:template name="body_inner"/>


    <xsl:template name="nav">
        <nav class="uk-navbar uk-margin-large-bottom">
            <a class="uk-navbar-brand uk-hidden-small" href="/">Parsekit</a>
            <ul class="uk-navbar-nav uk-hidden-small">
                <li>
                    <a href="/packages">Packages</a>
                </li>
                <li>
                    <a href="/login">Login</a>
                </li>
                <li>
                    <a href="/logout">Logout</a>
                </li>
            </ul>
            <a href="#offcanvas" class="uk-navbar-toggle uk-visible-small" data-uk-offcanvas=""></a>
            <div class="uk-navbar-brand uk-navbar-center uk-visible-small">Parsekit</div>
        </nav>
    </xsl:template>


</xsl:stylesheet>