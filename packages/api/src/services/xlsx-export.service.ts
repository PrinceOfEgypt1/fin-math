import ExcelJS from "exceljs";

export interface ScheduleRow {
  periodo: number;
  saldoInicial: number;
  pmt: number;
  juros: number;
  amortizacao: number;
  saldoFinal: number;
}

export async function exportToXLSX(
  schedule: ScheduleRow[],
  pv: number,
  i: number,
  n: number,
): Promise<Buffer> {
  const workbook = new ExcelJS.Workbook();
  const worksheet = workbook.addWorksheet("Cronograma");

  // Cabeçalhos
  worksheet.columns = [
    { header: "Período", key: "periodo", width: 10 },
    { header: "Saldo Inicial", key: "saldoInicial", width: 15 },
    { header: "PMT", key: "pmt", width: 12 },
    { header: "Juros", key: "juros", width: 12 },
    { header: "Amortização", key: "amortizacao", width: 15 },
    { header: "Saldo Final", key: "saldoFinal", width: 15 },
  ];

  // Dados com FÓRMULAS
  schedule.forEach((row, idx) => {
    const rowNum = idx + 2;

    worksheet.addRow({
      periodo: row.periodo,
      saldoInicial: row.saldoInicial,
      pmt: row.pmt,
      juros: { formula: `B${rowNum}*${i}` },
      amortizacao: { formula: `C${rowNum}-D${rowNum}` },
      saldoFinal: { formula: `B${rowNum}-E${rowNum}` },
    });
  });

  // Formatação moeda
  worksheet.getColumn("saldoInicial").numFmt = "R$ #,##0.00";
  worksheet.getColumn("pmt").numFmt = "R$ #,##0.00";
  worksheet.getColumn("juros").numFmt = "R$ #,##0.00";
  worksheet.getColumn("amortizacao").numFmt = "R$ #,##0.00";
  worksheet.getColumn("saldoFinal").numFmt = "R$ #,##0.00";

  // Totais
  const lastRow = schedule.length + 2;
  worksheet.addRow({
    periodo: "TOTAIS",
    pmt: { formula: `SUM(C2:C${lastRow - 1})` },
    juros: { formula: `SUM(D2:D${lastRow - 1})` },
    amortizacao: { formula: `SUM(E2:E${lastRow - 1})` },
  });

  const buffer = await workbook.xlsx.writeBuffer();
  return Buffer.from(buffer);
}
