const wrapper = document.getElementById('wrapper');

function setText(id, text) {
    const el = document.getElementById(id);
    if (el) el.innerText = text;
}

function applyTheme(theme) {
    if (!theme) return;
    const root = document.documentElement.style;
    if (theme.primaryColor) root.setProperty('--primary', theme.primaryColor);
    if (theme.accentColor) root.setProperty('--accent', theme.accentColor);
    if (theme.textColor) root.setProperty('--text', theme.textColor);
}

function render(data, labels) {
    document.getElementById('logo').src = data.serverLogo || '';
    setText('serverName', data.serverName || '');
    setText('title', labels.title || 'BOARDING PASS');

    setText('lblFrom', labels.from || 'FROM');
    setText('lblTo', labels.to || 'TO');
    setText('originCode', data.origin ? data.origin.code : '');
    setText('originName', data.origin ? data.origin.name : '');
    setText('destCode', data.destination ? data.destination.code : '');
    setText('destName', data.destination ? data.destination.name : '');

    setText('lblPassenger', labels.passenger || 'PASSENGER');
    setText('passengerName', data.passengerName || '');

    setText('lblFlight', labels.flight || 'FLIGHT');
    setText('flightNumber', data.flightNumber || '');

    setText('lblSeat', labels.seat || 'SEAT');
    setText('seat', data.seat || '');

    setText('lblGate', `${labels.gate || 'GATE'} / ${labels.terminal || 'TERM'}`);
    setText('gateTerminal', `${data.gate || ''} / ${data.terminal || ''}`);

    setText('lblClass', labels.class || 'CLASS');
    setText('travelClass', data.travelClass || '');

    setText('lblBoarding', labels.boarding_time || 'BOARDING TIME');
    setText('boardingTime', `${data.boardingDate || ''}  ${data.boardingTime || ''}`);

    setText('seatBig', `${labels.seat || 'SEAT'} ${data.seat || ''}`);
    setText('flightBig', `${data.flightNumber || ''} \u2022 ${data.gate || ''}`);

    setText('closeBtn', labels.nui_close || 'Close');
}

window.addEventListener('message', (event) => {
    const payload = event.data;
    if (!payload || !payload.action) return;

    if (payload.action === 'show') {
        applyTheme(payload.theme);
        render(payload.data, payload.labels || {});
        wrapper.classList.remove('hidden');
    } else if (payload.action === 'hide') {
        wrapper.classList.add('hidden');
    }
});

function resourceName() {
    return typeof window.GetParentResourceName === 'function' ? window.GetParentResourceName() : 'connect';
}

document.getElementById('closeBtn').addEventListener('click', () => {
    wrapper.classList.add('hidden');
    fetch(`https://${resourceName()}/close`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify({}),
    });
});

document.addEventListener('keyup', (e) => {
    if (e.key === 'Escape' && !wrapper.classList.contains('hidden')) {
        document.getElementById('closeBtn').click();
    }
});
