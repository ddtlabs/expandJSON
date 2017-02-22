
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
  
  <b>Define</b><br><br>
  
  <ul>
    <code>define &lt;name&gt; expandJSON &lt;source_regex&gt; [&lt;target_regex&gt;]</code><br><br>

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
      converted or not at all. If not set then all readings will be used. If set then only
      matching readings will be used. Regexp syntax is the same as used by
      notify and must not contain a space.<br>
      </li><br>

    <li>
      Examples:<br>
      <br>
      <u>Source reading:</u><br>
      <code>
        device:reading:.{.*}<br>
        .*WifiIOT.*:sensor.*:.{.*}<br>
        sonoff_.*:.*:.{.*}<br>
        dev.*:(sensor1|sensor2|teleme.*):.{.*}<br>
        (dev.*|[Dd]evice.*):json:.{.*}<br>
        (devX:jsonX:.{.*}|devY.*:jsonY:.{.*Wifi.*{.*SSID.*}.*})
      </code><br>
      <br>

      <u>Target reading:</u><br>
      <code>
        .*power.*<br>
        (Current|Voltage|Wifi.*)
      </code><br>
      <br>

      <u>Complete definitions:</u><br>
      <code>
        define ej1 expandJSON device:sourceReading:.{.*} targetReading<br>
        define ej3 expandJSON .*\.SEN\..*:.*:.{.*}<br>
        define ej3 expandJSON sonoff_.*:sensor.*:.{.*} power.*|current|voltage<br>
      </code><br>
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

    <li><b>disable</b></li>
    <li><b>disabledForIntervals</b></li>
    <li><b>addStateEvent</b></li>
    <li><b>showtime</b></li><br>
  </ul>
</ul>
