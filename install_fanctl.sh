#!/bin/sh

echo "[1/6] Install fanctl binary..."
cat << "EOT" > /usr/bin/fanctl
#!/bin/sh

CONFIG="fanctl"

find_paths() {
    PWM=""
    TEMP=""

    for d in /sys/class/hwmon/hwmon*; do
        [ -f "$d/pwm1" ] && PWM="$d/pwm1"
        [ -f "$d/temp1_input" ] && TEMP="$d/temp1_input"
    done

    [ -z "$PWM" ] && echo "PWM not found" && exit 1
    [ -z "$TEMP" ] && echo "TEMP not found" && exit 1

    ENABLE=$(dirname "$PWM")/pwm1_enable
}

enable_manual() {
    echo 1 > "$ENABLE"
}

load_config() {
    t1=$(uci get ${CONFIG}.@fan[0].t1 2>/dev/null || echo 45)
    t2=$(uci get ${CONFIG}.@fan[0].t2 2>/dev/null || echo 60)
    t3=$(uci get ${CONFIG}.@fan[0].t3 2>/dev/null || echo 75)

    p1=$(uci get ${CONFIG}.@fan[0].p1 2>/dev/null || echo 100)
    p2=$(uci get ${CONFIG}.@fan[0].p2 2>/dev/null || echo 160)
    p3=$(uci get ${CONFIG}.@fan[0].p3 2>/dev/null || echo 255)

    interval=$(uci get ${CONFIG}.@fan[0].interval 2>/dev/null || echo 5)
}

daemon() {
    find_paths
    load_config
    enable_manual

    LAST_PWM=-1

    while true; do
        t=$(cat "$TEMP")

        if [ "$t" -lt $((t1*1000)) ]; then
            target=$p1
        elif [ "$t" -lt $((t2*1000)) ]; then
            target=$p2
        else
            target=$p3
        fi

        if [ "$target" != "$LAST_PWM" ]; then
            echo "$target" > "$PWM"
            LAST_PWM="$target"
        fi

        sleep "$interval"
    done
}

menu() {
    find_paths
    enable_manual

    while true; do
        # Baca suhu dan PWM saat ini
        t=$(cat "$TEMP" 2>/dev/null)
        current_pwm=$(cat "$PWM" 2>/dev/null)
        temp_c=$((t / 1000))
        
        # Tampilan rapi
        printf "\n==================================\n"
        printf "        FAN CONTROL MENU\n"
        printf "==================================\n"
        printf " Temperature : %d°C\n" "$temp_c"
        printf " PWM Value   : %d / 255\n" "$current_pwm"
        printf "==================================\n"
        printf " 1) OFF        (PWM = 0)\n"
        printf " 2) Low        (PWM = 100)\n"
        printf " 3) Medium     (PWM = 160)\n"
        printf " 4) High       (PWM = 255)\n"
        printf " 5) Auto       (kembali ke daemon)\n"
        printf " 6) Exit CLI\n"
        printf "==================================\n"
        printf "Pilih [1-6]: "
        read opt

        case $opt in
            1) 
                echo "0" > "$PWM"
                printf "\n[INFO] Fan dimatikan (PWM=0)\n"
                sleep 1
                ;;
            2) 
                echo "100" > "$PWM"
                printf "\n[INFO] Fan kecepatan rendah (PWM=100)\n"
                sleep 1
                ;;
            3) 
                echo "160" > "$PWM"
                printf "\n[INFO] Fan kecepatan sedang (PWM=160)\n"
                sleep 1
                ;;
            4) 
                echo "255" > "$PWM"
                printf "\n[INFO] Fan kecepatan tinggi (PWM=255)\n"
                sleep 1
                ;;
            5) 
                printf "\n[INFO] Menjalankan mode daemon...\n"
                sleep 1
                daemon
                ;;
            6) 
                printf "\n[INFO] Keluar.\n"
                exit 0
                ;;
            *) 
                printf "\n[ERROR] Pilihan tidak valid, coba lagi.\n"
                sleep 1
                ;;
        esac
    done
}

case "$1" in
    daemon) daemon ;;
    *) menu ;;
esac
EOT

chmod +x /usr/bin/fanctl


echo "[2/6] Create config..."
cat << "EOT" > /etc/config/fanctl
config fan
    option t1 '45'
    option t2 '60'
    option t3 '75'

    option p1 '100'
    option p2 '160'
    option p3 '255'

    option interval '5'
EOT


echo "[3/6] Create init.d service..."
cat << "EOT" > /etc/init.d/fanctl
#!/bin/sh /etc/rc.common

START=99
USE_PROCD=1

start_service() {
    procd_open_instance
    procd_set_param command /usr/bin/fanctl daemon
    procd_set_param respawn
    procd_close_instance
}
EOT

chmod +x /etc/init.d/fanctl


echo "[4/6] Create LuCI menu..."
mkdir -p /usr/share/luci/menu.d
cat << "EOT" > /usr/share/luci/menu.d/fanctl.json
{
  "admin/services/fanctl": {
    "title": "Fan Control",
    "order": 90,
    "action": {
      "type": "view",
      "path": "fanctl"
    }
  }
}
EOT


echo "[5/6] Create LuCI JS view..."
mkdir -p /www/luci-static/resources/view
cat << "EOT" > /www/luci-static/resources/view/fanctl.js
'use strict';
'require view';
'require form';

return view.extend({
    render: function() {
        var m, s, o;

        m = new form.Map('fanctl', 'Fan Control');

        s = m.section(form.TypedSection, 'fan');
        s.anonymous = true;

        o = s.option(form.Value, 't1', 'Temp 1 (°C)');
        o = s.option(form.Value, 't2', 'Temp 2 (°C)');
        o = s.option(form.Value, 't3', 'Temp 3 (°C)');

        o = s.option(form.Value, 'p1', 'PWM 1');
        o = s.option(form.Value, 'p2', 'PWM 2');
        o = s.option(form.Value, 'p3', 'PWM 3');

        o = s.option(form.Value, 'interval', 'Interval (detik)');

        return m.render();
    }
});
EOT


echo "[6/6] Enable & start service..."
/etc/init.d/fanctl enable
/etc/init.d/fanctl restart

/etc/init.d/uhttpd restart

echo ""
echo "✅ INSTALL SELESAI"
echo "✅ LuCI: Services > Fan Control"
echo "✅ Binary: /usr/bin/fanctl"
