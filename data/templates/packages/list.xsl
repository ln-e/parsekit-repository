<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:import href="../_base.xsl" />

    <xsl:output indent="no" omit-xml-declaration="yes" method="html" />


    <xsl:template name="body_inner">
        <div class="">

            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Name</th>
                        <th>Type</th>
                        <th>Description</th>
                        <th>Keywords</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:apply-templates select="packages/item" mode="packages_list" />
                </tbody>
            </table>

            <form action="/package/add" class="form">
                <fieldset>
                    <input type="text" name="package" placeholder="vendor/name" />
                    <button type="submit" class="btn btn-primary">Add package</button>
                </fieldset>
            </form>

        </div>
    </xsl:template>


    <xsl:template match="item" mode="packages_list">
        <tr>
            <td>
                <xsl:value-of select="position()"/>
            </td>
            <td>
                <xsl:value-of select="name"/>
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
            <td>
                <a href="package/{id}">show</a>
            </td>
        </tr>
    </xsl:template>

</xsl:stylesheet>
