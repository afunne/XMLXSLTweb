<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>

  <xsl:template match="/">
    <h2>Lennureisid (sorteeritud hinnangu järgi)</h2>

    <!-- ainult need reisid, mille transport sisaldab lennukit; parima hinnanguga eespool -->
    <xsl:for-each select="//suund[transport/liik = 'lennuk']">
      <xsl:sort select="hinnang" data-type="number" order="descending"/>

      <h1><xsl:value-of select="@id"/></h1>
      <p>
        <xsl:value-of select="concat(nimetus, ', ', ../@aasta, ', ', pikkus, ' päeva, hinnang ', hinnang)"/>
        <!-- oma tingimus: kõrge hinnang tõstetakse esile -->
        <xsl:if test="hinnang &gt;= 4.5">
          <strong style="color: green;"> - Soovitame!</strong>
        </xsl:if>
      </p>

      <ul>
        <li>
          <xsl:attribute name="style">background-color: yellow;</xsl:attribute>
          <xsl:text>Transport: </xsl:text>
          <xsl:for-each select="transport/liik">
            <xsl:value-of select="."/>
            <xsl:if test="position() != last()">, </xsl:if>
          </xsl:for-each>
          <xsl:value-of select="concat(' - ', transport/hind, ' €')"/>
        </li>
        <li>
          <xsl:attribute name="style">background-color: yellow;</xsl:attribute>
          <xsl:value-of select="concat('Majutus: ', majutus/hind, ' €')"/>
        </li>
        <li>
          <xsl:attribute name="style">background-color: yellow;</xsl:attribute>
          <xsl:text>Ekskursioonid: </xsl:text>
          <xsl:for-each select="ekskursioonid/ekskursioon">
            <xsl:value-of select="concat(nimi, ' (', hind, ' €)')"/>
            <xsl:if test="position() != last()">, </xsl:if>
          </xsl:for-each>
        </li>
        <li>
          <xsl:attribute name="style">background-color: yellow;</xsl:attribute>
          <xsl:value-of select="concat('Muud kulud: ', muud/hind, ' €')"/>
        </li>
      </ul>

      <p>
        <strong>
          <xsl:value-of select="concat('Kogumaksumus: ', transport/hind + majutus/hind + sum(ekskursioonid/ekskursioon/hind) + muud/hind, ' €')"/>
        </strong>
      </p>
    </xsl:for-each>

    <h2>Kõik reisid tabelina</h2>
    <table class="table">
      <thead>
        <tr>
          <th>Aasta</th>
          <th>Suund</th>
          <th>Nimetus</th>
          <th>Pikkus</th>
          <th>Hinnang</th>
          <th>Transport</th>
          <th>Transport €</th>
          <th>Majutus €</th>
          <th>Ekskursioonid</th>
          <th>Ekskursioonid €</th>
          <th>Muud €</th>
        </tr>
      </thead>
      <tbody>
        <xsl:for-each select="//suund">
          <tr>
            <!-- üle rea erinev värv -->
            <xsl:attribute name="style">
              <xsl:choose>
                <xsl:when test="position() mod 2 = 1">background-color: #cfe8ff;</xsl:when>
                <xsl:otherwise>background-color: #ffffff;</xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <td><xsl:value-of select="../@aasta"/></td>
            <td><xsl:value-of select="@id"/></td>
            <td><xsl:value-of select="nimetus"/></td>
            <td><xsl:value-of select="pikkus"/></td>
            <td><xsl:value-of select="hinnang"/></td>
            <td>
              <xsl:for-each select="transport/liik">
                <xsl:value-of select="."/>
                <xsl:if test="position() != last()">, </xsl:if>
              </xsl:for-each>
            </td>
            <td><xsl:value-of select="transport/hind"/></td>
            <td><xsl:value-of select="majutus/hind"/></td>
            <td>
              <xsl:for-each select="ekskursioonid/ekskursioon">
                <xsl:value-of select="nimi"/>
                <xsl:if test="position() != last()">, </xsl:if>
              </xsl:for-each>
            </td>
            <td><xsl:value-of select="sum(ekskursioonid/ekskursioon/hind)"/></td>
            <td><xsl:value-of select="muud/hind"/></td>
          </tr>
        </xsl:for-each>
      </tbody>
    </table>
  </xsl:template>
</xsl:stylesheet>
