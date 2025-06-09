import 'dart:math';

class NauiService {
  /// Exemplo de tabela simplificada de grupos NAUI
  /// (Profundidade máxima -> Tempo limite de não descompressão e grupos de saturação)
  /// Este é um modelo didático simplificado. Pode ser calibrado depois.

  static final Map<int, List<int>> tabelaLimiteNDL = {
    10: [219, 180, 150, 120, 100, 80, 60, 40, 20],
    15: [100, 80, 60, 50, 40, 30, 20, 10],
    20: [50, 40, 30, 25, 20, 15, 10],
    25: [30, 25, 20, 15, 10],
    30: [20, 15, 10],
    35: [15, 10],
    40: [10],
  };

  static final List<String> grupos = [
    'A','B','C','D','E','F','G','H','I','J','K','L','M',
    'N','O','P','Q','R','S','T','U','V','W','X','Y','Z'
  ];

  /// Calcula a pressão absoluta com base na altitude e profundidade
  static double calcularPressaoAbsoluta(int profundidade, double pressaoAmbiente) {
    return pressaoAmbiente + (profundidade / 10);
  }

  /// Calcula o grupo NAUI baseado na profundidade e tempo de fundo
  static String calcularGrupoNaui(int profundidade, int tempoFundo, double pressaoAmbiente) {
    int profundidadeCorrigida = ajustarProfundidadeParaTabela(profundidade);

    final limites = tabelaLimiteNDL[profundidadeCorrigida];
    if (limites == null) return 'Z';

    for (int i = 0; i < limites.length; i++) {
      if (tempoFundo <= limites[i]) {
        return grupos[i];
      }
    }
    return 'Z';
  }

  /// Ajusta a profundidade para os degraus da tabela
  static int ajustarProfundidadeParaTabela(int profundidade) {
    if (profundidade <= 10) return 10;
    if (profundidade <= 15) return 15;
    if (profundidade <= 20) return 20;
    if (profundidade <= 25) return 25;
    if (profundidade <= 30) return 30;
    if (profundidade <= 35) return 35;
    return 40;
  }

  /// Converte o grupo NAUI em percentual de saturação (ex.: Z = 100%)
  static int grupoNauiParaPercentual(String grupo) {
    int indice = grupos.indexOf(grupo);
    if (indice == -1) return 100;
    return ((indice / (grupos.length - 1)) * 100).round();
  }
}
