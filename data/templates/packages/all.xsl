<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:import href="../_base.xsl" />

    <xsl:output indent="no" omit-xml-declaration="yes" method="html" />


    <xsl:template name="page_title">Last 10 added packages</xsl:template>


    <xsl:template name="body_inner">
        <div>
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>Name</th>
                        <th>Type</th>
                        <th>Description</th>
                        <th>Keywords</th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:apply-templates select="packages/item" mode="packages_list" />
                </tbody>
            </table>
        </div>
    </xsl:template>


    <xsl:template match="item" mode="packages_list">
        <tr>
            <td>
                <a href="package/{id}">
                    <xsl:value-of select="name"/>
                </a>
            </td>
            <td>
                <xsl:value-of select="type"/>
            </td>
            <td>
                <xsl:value-of select="description"/>
            </td>
            <td>
                <xsl:value-of select="keywords"/>
            </td>
        </tr>
    </xsl:template>

</xsl:stylesheet>
