<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Weekly Shifts Calendar</title>
<style>
  table { border-collapse: collapse; width: 100%; }
  th, td { border: 1px solid #ccc; padding: 5px; text-align: center; vertical-align: top; }
  th { background-color: #f0f0f0; }
  .shift-type { font-weight: bold; }
  .notes { font-size: 0.8em; color: #555; }
</style>
</head>
<body>
<h2>Weekly Shifts</h2>
<table id="shiftTable">
  <thead>
    <tr id="headerRow"><th>Employee</th></tr>
  </thead>
  <tbody id="tableBody"></tbody>
</table>

<script>
const flowUrl = "https://default14011d5f65a54d3ebecc2894a6bafb.41.environment.api.powerplatform.com:443/powerautomate/automations/direct/workflows/b7f91d89b354418aa08f5cce64e2d4af/triggers/manual/paths/invoke/?api-version=1"; // <-- replace with your HTTP URL

function formatDate(dateStr) {
  const d = new Date(dateStr);
  return d.toISOString().split('T')[0];
}

async function loadShifts() {
  try {
    const response = await fetch(flowUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ days: 7 })
    });

    if (!response.ok) {
      throw new Error('HTTP error ' + response.status);
    }

    const data = await response.json();

    // Get unique employees and dates
    const employees = [...new Set(data.map(item => item.Employee))].sort();
    const dates = [...new Set(data.map(item => formatDate(item.Date)))].sort();

    // Build table header
    const headerRow = document.getElementById("headerRow");
    dates.forEach(d => {
      const th = document.createElement("th");
      th.textContent = d;
      headerRow.appendChild(th);
    });

    // Build table body
    const tableBody = document.getElementById("tableBody");
    employees.forEach(emp => {
      const tr = document.createElement("tr");
      const tdName = document.createElement("td");
      tdName.textContent = emp;
      tr.appendChild(tdName);

      dates.forEach(date => {
        const td = document.createElement("td");
        const shift = data.find(s => s.Employee === emp && formatDate(s.Date) === date);
        if (shift) {
          td.innerHTML = `<div class="shift-type">${shift.ShiftType}</div><div class="notes">${shift.Notes || ''}</div>`;
        }
        tr.appendChild(td);
      });

      tableBody.appendChild(tr);
    });

  } catch (err) {
    console.error("Error fetching shifts:", err);
    const tableBody = document.getElementById("tableBody");
    tableBody.innerHTML = "<tr><td colspan='8'>Failed to load shifts</td></tr>";
  }
}

loadShifts();
</script>
</body>
</html>
