
<h3>expandJSON v1.08</h3>

<ul>
  <p>Expand a JSON string from a reading into individual readings</p>

  <ul>
    <li>Requirement: perl module JSON<br>
      Use "cpan install JSON" or operating system's package manager to install
      Perl JSON Modul. Depending on your os the required package is named: 
      libjson-perl or perl-JSON.
    </li>
  </ul><br>
  
  <b>Define</b><br><br>
  
  <ul>
    <code>define &lt;name&gt; expandJSON &lt;source_regex&gt; 
      [&lt;target_regex&gt;]</code><br><br>

    <li>
      <b>&lt;name&gt;</b><br>
      A name of your choice.</li><br>

    <li>
      <b>&lt;source_regex&gt;</b><br>
      Regexp that must match your devices, readings and values that contain
      the JSON strings. Regexp syntax is the same as used by notify and must not
      contain a space.<br>
      </li><br>
      
    <li>
      <b>&lt;target_regex&gt;</b><br>
      Optional: This regexp is used to determine whether the target reading is
      converted or not at all. If not set then all readings will be used. If set
      then only matching readings will be used. Regexp syntax is the same as
      used by notify and must not contain a space.<br>
      </li><br>

    <li>
      Examples:<br>
      <br>
      <u>Source reading:</u><br>
        <code>device:reading:.{.*}</code><br>
        <code>.*WifiIOT.*:sensor.*:.{.*}</code><br>
        <code>sonoff_.*:.*:.{.*}</code><br>
        <code>dev.*:(sensor1|sensor2|teleme.*):.{.*}</code><br>
        <code>(dev.*|[Dd]evice.*):json:.{.*}</code><br>
        <code>(devX:jsonX:.{.*}|devY.*:jsonY:.{.*Wifi.*{.*SSID.*}.*})</code><br>
      <br>

      <u>Target reading:</u><br>
        <code>.*power.*</code><br>
        <code>(Current|Voltage|Wifi.*)</code><br>
      <br>

      <u>Complete definitions:</u><br>
        <code>define ej1 expandJSON device:sourceReading:.{.*} targetReading</code><br>
        <code>define ej3 expandJSON .*\.SEN\..*:.*:.{.*}</code><br>
        <code>define ej3 expandJSON sonoff_.*:sensor.*:.{.*} (power.*|current|voltage)</code><br>
      <br>
    </li><br>
  </ul>

  <b>Set</b><br><br>
  <ul>
    N/A<br><br>
  </ul>
  
  <b>Get</b><br><br>
  <ul>
    N/A<br><br>
  </ul>
  
  <b>Attributes</b><br><br>
  <ul>
    <li><b>addReadingsPrefix</b><br>
      Add source reading as prefix to new generated readings. Useful if you have
      more than one reading with a JSON string that should be converted.
    </li><br>

    <li><b>disable</b><br>
      Used to disable this device.
    </li><br>
    
    <li><b>do_not_notify</b><br>
      Do not generate events for converted readings at all. Think twice before
      using this attribute. In most cases, it is more appropriate to use 
      event-on-change-reading in target devices.
    </li><br>

    <li><b>disabledForIntervals</b></li>
    <li><b>addStateEvent</b></li>
    <li><b>showtime</b></li><br>
  </ul>
</ul>
