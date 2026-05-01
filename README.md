# fanctl - Fan Control untuk OpenWrt

Script kontrol kipas PWM untuk OpenWrt dengan mode otomatis (daemon) dan manual (CLI menu).

## Fitur
- Mode otomatis (daemon) berdasarkan suhu
- Mode manual interaktif (CLI)
- Konfigurasi via UCI
- Support init.d / procd (auto start)
- Support LuCI web interface (optional)

## Instalasi

Jalankan installer:
```bash
chmod +x install_fanctl.sh
./install_fanctl.sh
```

Atau manual:

```bash
chmod +x /usr/bin/fanctl
/etc/init.d/fanctl enable
/etc/init.d/fanctl start
```

Konfigurasi

File: /etc/config/fanctl

```uci
config fan
    option t1 '45'        # °C, di bawah ini -> p1
    option t2 '60'        # °C, antara t1-t2 -> p2
    option t3 '75'        # °C, di atas t3 -> p3
    option p1 '100'       # PWM 0-255
    option p2 '160'
    option p3 '255'
    option interval '5'   # detik
```

Ubah via CLI:

```bash
uci set fanctl.@fan[0].t1=50
uci commit fanctl
/etc/init.d/fanctl restart
```

Penggunaan

Mode daemon (auto)

```bash
fanctl daemon
```

atau

```bash
/etc/init.d/fanctl start
```

Mode menu interaktif

```bash
fanctl
```

Menu:

```
1) OFF        (PWM=0)
2) Low        (PWM=100)
3) Medium     (PWM=160)
4) High       (PWM=255)
5) Auto       (kembali ke daemon)
6) Exit CLI
```

LuCI

Menu: Services > Fan Control

Troubleshooting

Cek apakah PWM dan temperature terdeteksi:

```bash
ls /sys/class/hwmon/hwmon*/
cat /sys/class/hwmon/hwmon*/temp1_input
cat /sys/class/hwmon/hwmon*/pwm1
```

Restart web UI jika LuCI tidak muncul:

```bash
/etc/init.d/uhttpd restart
```

Struktur File

```
/usr/bin/fanctl                         # binary utama
/etc/config/fanctl                      # konfigurasi UCI
/etc/init.d/fanctl                      # init script
/usr/share/luci/menu.d/fanctl.json      # menu LuCI
/www/luci-static/resources/view/fanctl.js # tampilan LuCI
```
