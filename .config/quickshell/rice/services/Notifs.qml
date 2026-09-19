pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// Servidor de notificações (org.freedesktop.Notifications) — substitui o dunst no Hyprland.
// Histórico = notificações rastreadas; popups = subconjunto temporário; modo Não Perturbe.
Singleton {
    id: root

    property bool dnd: false
    property var popups: []          // objetos Notification em exibição como popup
    property var times: ({})         // id -> Date.now() de chegada
    property int unread: 0
    readonly property var list: server.trackedNotifications.values.slice().reverse()   // mais recentes primeiro
    readonly property int count: server.trackedNotifications.values.length
    readonly property int defaultTimeout: 6000

    NotificationServer {
        id: server
        keepOnReload: true
        persistenceSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: false
        actionsSupported: true
        actionIconsSupported: true
        imageSupported: true
        inlineReplySupported: false

        onNotification: notif => {
            notif.tracked = true;
            const t = Object.assign({}, root.times);
            t[notif.id] = Date.now();
            root.times = t;
            if (!Ui.anyPanel || Ui.panel !== "notifications")
                root.unread += 1;
            if (!root.dnd || notif.urgency === NotificationUrgency.Critical)
                root.showPopup(notif);
        }
    }

    function showPopup(n): void {
        const p = root.popups.filter(x => x !== n && x.id !== n.id);
        p.unshift(n);
        root.popups = p.slice(0, 5);
    }
    function hidePopup(n): void {
        root.popups = root.popups.filter(x => x !== n);
    }
    function dismiss(n): void {
        hidePopup(n);
        n.dismiss();
    }
    function clearAll(): void {
        root.popups = [];
        for (const n of server.trackedNotifications.values.slice())
            n.dismiss();
        root.unread = 0;
    }
    function invokeDefault(n): bool {
        const acts = n.actions || [];
        const def = acts.find(a => a.identifier === "default");
        if (def) {
            def.invoke();
            return true;
        }
        return false;
    }
    function markRead(): void {
        root.unread = 0;
    }
    function timeout(n): int {
        if (n.urgency === NotificationUrgency.Critical)
            return 0;
        return n.expireTimeout > 0 ? Math.max(2500, n.expireTimeout) : root.defaultTimeout;
    }
    function ago(n): string {
        const t = root.times[n.id];
        if (!t)
            return "";
        const s = Math.floor((Date.now() - t) / 1000);
        if (s < 60)
            return "agora";
        if (s < 3600)
            return Math.floor(s / 60) + " min";
        if (s < 86400)
            return Math.floor(s / 3600) + " h";
        return Qt.formatDateTime(new Date(t), "dd/MM HH:mm");
    }
    function appIcon(n): string {
        if (!n)
            return "";
        if (n.appIcon && n.appIcon !== "")
            return n.appIcon;
        const e = DesktopEntries.heuristicLookup(n.desktopEntry || n.appName || "");
        return e ? e.icon : "";
    }
    // URL utilizável para o ícone do app (nome de tema, caminho absoluto ou URL)
    function iconSource(n): string {
        const i = appIcon(n);
        if (i === "")
            return "";
        if (i.startsWith("/"))
            return "file://" + i;
        if (i.startsWith("file://") || i.startsWith("image://"))
            return i;
        return Quickshell.iconPath(i, true);
    }
    // corpo: o servidor anuncia suporte a markup; remove tags não suportadas pelo StyledText
    function cleanBody(b: string): string {
        return (b || "").replace(/<img[^>]*>/gi, "").replace(/\n/g, "<br/>");
    }

    // relógio para atualizar "há X min"
    property int tick: 0
    Timer {
        interval: 30000
        running: root.count > 0
        repeat: true
        onTriggered: root.tick++
    }
}
