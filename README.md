

🔧 One-line install

Salin dan tempel perintah berikut di terminal OpenWrt:

```bash
wget -O /tmp/install_fanctl.sh https://raw.githubusercontent.com/zainalicious/Openwrt-Fan-Control/main/install_fanctl.sh && chmod +x /tmp/install_fanctl.sh && /tmp/install_fanctl.sh
```

Perintah di atas akan:

1. Mengunduh script installer ke /tmp
2. Memberi izin eksekusi
3. Menjalankan installer secara otomatis

---

📦 Atau dengan curl (jika wget tidak tersedia)

```bash
curl -L -o /tmp/install_fanctl.sh https://raw.githubusercontent.com/zainalicious/Openwrt-Fan-Control/main/install_fanctl.sh && chmod +x /tmp/install_fanctl.sh && /tmp/install_fanctl.sh
```

---

✅ Setelah instalasi

· Jalankan menu interaktif: fanctl


· Akses LuCI: Services → Fan Control

---

🧹 Uninstall (1 baris)

```bash
wget -O /tmp/uninstall_fanctl.sh https://raw.githubusercontent.com/zainalicious/Openwrt-Fan-Control/main/uninstall_fanctl.sh && chmod +x /tmp/uninstall_fanctl.sh && /tmp/uninstall_fanctl.sh
```

---

