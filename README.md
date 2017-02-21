
<div id="devSpecHelp">
<a name="expandJSON"></a>
<h3>expandJSON</h3>

<ul>
  <p>Expand a JSON string from a reading into individual readings</p>

  <ul>
    <li>Requirement: perl module JSON<br>
      Use "cpan install JSON" or operating system's package manager to install
      Perl JSON Modul. Depending on your os the required package is named: 
      libjson-perl or perl-JSON.
    </li>
  </ul><br>
  
  <a name="expandJSONdefine"></a>
  <b>Define</b><br><br>
  
  <ul>
    <code>define &lt;name&gt; expandJSON &lt;regex&gt;</code><br><br>

    <li>
      <code>&lt;name&gt;</code><br>
      A name of your choice.</li><br>

    <li>
      <code>&lt;regex&gt;</code><br>
      Regexp that must match your devices, readings and values that contain
      the JSON strings. Regepx syntax is the same as used by notify.<br>
      eg. <code>device:reading:.value</code></li><br>

    <li>
      Examples:<br>
      <code>define ej1 expandJSON device:reading:.{.*}</code><br>
      <code>define ej2 expandJSON sonoff_123:sensor.*:.*</code><br>
      <code>define ej3 expandJSON sonoff_.*:.*:.{.*}</code><br>
      <code>define ej4 expandJSON .*:sensor:.*</code><br>
      <code>define ej5 expandJSON .*:(sensor1|sensor2|teleme.*):.*</code><br>
      <code>define ej6 expandJSON (dev1|device.*|[Dd]evice.*):reading:.*</code><br>
      <code>define ej7 expandJSON (dev0\d+|[Dd]evice.*):(sen1|sen2|telem.*):.*</code><br>
      <code>define ej8 expandJSON d.*:jsonX:.{.*}|y.*:jsonY:.{.*Wifi.*{.*SSID.*}.*}</code></li><br>
  </ul>

  <a name="expandJSONset"></a>
  <b>Set</b><br><br>
  <ul>
    N/A<br><br>
  </ul>
  
  <a name="expandJSONget"></a>
  <b>Get</b><br><br>
  <ul>
    N/A<br><br>
  </ul>
  
  <a name="expandJSONattr"></a>
  <b>Attributes</b><br><br>
  <ul>
    <li><a name="">addReadingsPrefix</a><br>
      Add source reading as prefix to new generated readings. Useful if you have
      more than one reading with a JSON string that should be converted.
    </li><br>

    <li><a target="_blank" href="/fhem/docs/commandref.html#disable">disable</a></li>
    <li><a target="_blank" href="/fhem/docs/commandref.html#disabledForIntervals">disabledForIntervals</a></li>
    <li><a target="_blank" href="/fhem/docs/commandref.html#addStateEvent">addStateEvent</a></li>
    <li><a target="_blank" href="/fhem/docs/commandref.html#showtime">showtime</a></li><br>
  </ul>
</ul>


</div>
