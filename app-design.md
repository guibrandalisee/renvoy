# 5 Pilares para um Aplicativo Ser Percebido como Premium

Para que um aplicativo seja percebido como **premium** e de **alta qualidade**, a chave não está apenas na implementação técnica, mas no acúmulo de detalhes sutis que melhoram a experiência do usuário.

Com base na experiência compartilhada no vídeo e nas dicas do [Flutter Pro Design](https://flutterpro.design/), estes são os **5 pilares fundamentais** para criar essa percepção de qualidade.

---

## 1. Estados de Pressionamento e Física de Mola

O aplicativo deve responder visualmente ao toque do usuário. Pequenas animações de escala, opacidade ou movimento ao pressionar botões comunicam que o sistema detectou a intenção do usuário.

Esse tipo de detalhe faz com que a interface pareça mais viva, responsiva e confiável.

### Boas práticas

- Aplicar animações sutis de escala ao pressionar botões.
- Usar mudanças leves de opacidade para reforçar o feedback visual.
- Implementar física de mola para deixar a interação mais natural.
- Permitir que o usuário cancele um gesto ao arrastar o dedo para fora do botão.

A capacidade de cancelar uma ação durante o toque é um detalhe crucial. Ela dá ao usuário uma sensação de controle refinado, parecida com a de aplicativos nativos bem acabados.

> Exemplo de ferramenta citada: **Presto**.

---

## 2. Animações Sutis

Em aplicativos premium, animações não devem chamar mais atenção do que o próprio conteúdo. O princípio é simples: **menos é mais**.

Animações excessivas cansam o usuário e podem fazer o app parecer amador. O ideal é usar transições suaves, rápidas e discretas, que apenas reforcem a sensação de fluidez.

### Boas práticas

- Usar transições de `fade-in` ao carregar elementos.
- Aplicar animações suaves ao navegar entre telas.
- Evitar movimentos exagerados ou efeitos chamativos demais.
- Priorizar transições nativas da plataforma sempre que possível.

Transições nativas, como os **zoom transitions do iOS 18**, ajudam o aplicativo a parecer um software realmente nativo, e não apenas um site empacotado dentro de um app.

---

## 3. Uso Estratégico de Hápticos

O feedback háptico, ou seja, pequenas vibrações físicas, gera uma sensação de confiança e precisão. Quando usado corretamente, ele faz a interface parecer mais tátil e responsiva.

O segredo está em usar hápticos apenas nos momentos certos. Vibrações demais deixam o app cansativo; vibrações bem colocadas reforçam ações importantes.

### Boas práticas

- Usar hápticos para confirmar ações bem-sucedidas.
- Aplicar feedback físico ao alternar botões ou switches.
- Usar vibrações curtas ao arrastar seletores ou sliders.
- Evitar vibração em interações muito frequentes ou irrelevantes.

> Exemplo de ferramenta citada: **Pulsar**.

Ferramentas desse tipo ajudam a implementar padrões de vibração que parecem naturais, precisos e agradáveis.

---

## 4. Comportamento do Teclado

O comportamento do teclado é um dos detalhes que mais separam aplicativos profissionais de aplicativos medianos.

Apps de baixa qualidade frequentemente deixam o teclado cobrir campos de texto, travar a interface ou aparecer de forma brusca. Já apps premium integram o teclado de maneira fluida à experiência.

### Boas práticas

- Mover campos de input automaticamente quando o teclado aparece.
- Evitar que o teclado cubra botões ou informações importantes.
- Permitir gestos de deslize para fechar o teclado.
- Fazer elementos da interface crescerem, reduzirem ou se adaptarem ao teclado.
- Garantir que a experiência pareça natural tanto no iOS quanto no Android.

> Exemplo de ferramenta citada: **React Native Keyboard Controller**.

Esse tipo de fluidez diferencia um projeto profissional de uma interface simples ou gerada automaticamente sem refinamento.

---

## 5. Estados de Carregamento e Estados Vazios

Um aplicativo premium nunca deve deixar o usuário diante de uma tela vazia, confusa ou sem direção.

Estados de carregamento e estados vazios são momentos importantes da experiência. Eles mostram cuidado, orientação e acabamento visual.

### Estados vazios

Use **empty states** bem desenhados para explicar o que está acontecendo e orientar o usuário sobre o próximo passo.

Um bom estado vazio deve:

- Explicar por que ainda não há conteúdo naquela tela.
- Indicar o que o usuário pode fazer para começar.
- Ter visual limpo e coerente com o restante do app.
- Evitar mensagens genéricas ou frias demais.

### Estados de carregamento

Substitua o clássico spinner sempre que possível por elementos mais modernos e contextuais.

Uma alternativa melhor é o uso de **shimmer loading**, que simula o formato do conteúdo enquanto ele está carregando.

Quando um spinner for realmente necessário, evite deixar o `CircularProgressIndicator` do Material vazar para dentro de uma interface customizada. Use um indicador neutro, com cor, tamanho e espessura alinhados ao design do app.

### Boas práticas

- Evitar telas completamente em branco.
- Usar skeleton loading ou shimmer em listas e cards.
- Usar um spinner neutro quando o carregamento não tiver formato previsível.
- Criar empty states com ilustrações, textos claros e chamadas para ação.
- Fazer o carregamento parecer parte da interface, e não uma interrupção.

---

## Dicas Extras de Acabamento em Flutter

O [Flutter Pro Design](https://flutterpro.design/) reforça a mesma ideia central: a percepção de qualidade nasce de pequenos detalhes que o usuário talvez nem saiba nomear, mas sente quando estão ausentes.

### Interação e feedback

- Remover efeitos Material que não combinam com a identidade visual do app, como ripple, highlight e overlays de toque, quando a interface usa uma linguagem própria.
- Usar um componente `Pressable` reutilizável com escala e física de mola para botões, cards e elementos tocáveis.
- Escolher hápticos por intenção: `success` para conclusão, `warning` para atenção, `error` para falhas, `selection` para seletores, e impactos leves ou médios para ações comuns.
- Mostrar uma prévia de ações escondidas por swipe, como editar ou excluir em uma lista, apenas uma vez para ensinar o gesto sem incomodar.
- Fazer listas parecerem scrolláveis com fade nas bordas, especialmente em pickers, listas longas e carrosséis.

### Teclado e foco

- Fechar o teclado antes de abrir um modal, usando `FocusManager.instance.primaryFocus?.unfocus()`, para evitar que o foco anterior volte quando o modal fecha.
- Usar `keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag` em formulários e buscas, quando rolar a tela significa que o usuário terminou de digitar.
- Evitar esse comportamento em chats, onde o usuário pode querer rolar mensagens antigas enquanto continua escrevendo.
- Em telas com um único campo, como OTP, telefone ou troca de e-mail, usar `autofocus: true` e submeter automaticamente quando o input estiver completo.

### Layout, listas e áreas seguras

- Evitar `SafeArea` envolvendo scrollables quando isso corta o conteúdo; prefira adicionar padding inferior dinâmico com `MediaQuery.viewPaddingOf(context).bottom`.
- Em telas sem `AppBar`, aplicar um fade progressivo no topo quando o conteúdo passa por trás da status bar, evitando colisão visual com relógio, bateria e indicadores do sistema.
- Não colocar padding horizontal no scroll principal quando a tela tem listas horizontais. Deixe a página edge-to-edge e aplique padding em cada seção.
- Em tabs horizontais customizadas, usar `Scrollable.ensureVisible` para garantir que a aba selecionada fique totalmente visível.
- Ao tocar novamente na tab atual da bottom navigation, rolar a tela para o topo; se já estiver no topo, focar a busca quando fizer sentido.
- No iOS, garantir que o toque na status bar role a tela para o topo, conectando `PrimaryScrollController` quando houver controller customizado.
- Em mobile, adicionar scrollbars manualmente ou via `ScrollBehavior` quando elas melhorarem a orientação, sem duplicar as barras automáticas de desktop.

### Imagens, fontes e assets

- Reservar espaço para imagens antes do carregamento com `AspectRatio`, `SizedBox` ou um pai com altura fixa, evitando saltos de layout.
- Carregar imagens com transição suave, placeholder simples e erro discreto; evite spinners chamativos dentro de imagens.
- Pré-carregar ícones e assets críticos durante a splash screen para evitar que apareçam com atraso de um ou dois frames.
- Pré-carregar pesos e estilos usados pelo `google_fonts` antes da primeira tela para evitar troca brusca da fonte padrão para a fonte final.

### Texto, números e dados

- Nunca exibir `null`, string vazia ou `"null"` para o usuário; use placeholder claro ou esconda o componente.
- Formatar números com `intl` quando o usuário lê como quantidade, moeda ou valor. Não formatar quando o número funciona como identificador.
- Usar `FontFeature.tabularFigures()` em timers, contadores, preços, totais, códigos e números em listas para evitar que a UI fique "pulando".
- Limitar o `textScaler` apenas quando necessário para evitar overflow, sem ignorar completamente a preferência de acessibilidade do usuário.
- Personalizar `textSelectionTheme` para cursor, seleção e handles combinarem com a marca e manterem contraste.

### Web, plataforma e sistema

- Em Flutter Web, mostrar progresso real de carregamento no `index.html`/`flutter_bootstrap.js` para evitar a primeira tela em branco.
- Atualizar o título da aba do navegador por rota usando `Title`, para que histórico, favoritos e abas abertas sejam fáceis de reconhecer.
- Adicionar tags Open Graph e Twitter no `head` do Flutter Web para que links compartilhados tenham preview com título, descrição e imagem. A imagem deve usar URL absoluta e proporção adequada para preview social.
- Desativar transições de página em web e desktop; manter transições nativas em Android e iOS.
- Usar date picker adaptativo: `CupertinoDatePicker` no iOS e `showDatePicker` Material no Android.
- Usar sheets adaptativas: no iOS, sheets modernas com cantos arredondados e botão de fechar; no Android, uma sheet simples ou rota Material que pareça natural na plataforma.
- Em modais que sobem de baixo, preferir botão de fechar no topo em vez de seta de voltar, porque a affordance é de dismiss, não de navegação para trás.
- Abrir links de redes sociais com URLs normais em modo `externalApplication`, deixando o sistema abrir o app instalado quando possível.
- Para "baixar" arquivos, considerar salvar em cache e abrir a share sheet do sistema, evitando permissões e pastas públicas quando o objetivo é compartilhar ou salvar.
- Mostrar a versão, build e patch do app em uma área discreta de configurações para facilitar suporte e QA.
- Exibir changelog após atualizações, sem mostrar no primeiro install, para comunicar melhorias e correções que o usuário talvez não perceba.
- Reagendar notificações quando o timezone ou o offset do relógio mudar, principalmente em lembretes sensíveis a horário local.
- No Android, habilitar `android:enableOnBackInvokedCallback="true"` quando modais não fecharem com o botão ou gesto de voltar, migrando de `WillPopScope` para `PopScope` antes.

---

## Conclusão

O sentimento de **premium** não vem de uma única funcionalidade isolada.

Ele nasce da soma de dezenas de pequenas decisões de design, interação e acabamento. Estados de toque, animações sutis, hápticos, teclado fluido, carregamentos elegantes e bons estados vazios criam uma experiência que transmite qualidade.

Em outras palavras: um app premium é aquele que parece ter sido cuidadosamente pensado em cada detalhe.

---

## Checklist Rápido

- [ ] Botões possuem feedback visual ao toque.
- [ ] Gestos podem ser cancelados quando o usuário arrasta o dedo para fora.
- [ ] Animações são suaves, rápidas e discretas.
- [ ] Transições nativas da plataforma são usadas quando possível.
- [ ] Hápticos são aplicados em ações importantes.
- [ ] O teclado não cobre elementos essenciais.
- [ ] Inputs se adaptam corretamente ao teclado.
- [ ] Telas vazias possuem mensagens claras e úteis.
- [ ] Carregamentos usam shimmer ou skeleton loading.
- [ ] Spinners, quando usados, são neutros e combinam com a interface.
- [ ] Nenhuma tela importante fica em branco ou sem orientação.
- [ ] O teclado fecha antes de modais e ao rolar formulários quando apropriado.
- [ ] Telas de input único usam autofocus e reduzem taps desnecessários.
- [ ] Imagens têm espaço reservado antes de carregar.
- [ ] Ícones, fontes e assets críticos são pré-carregados.
- [ ] Telas sem `AppBar` usam fade progressivo quando o conteúdo passa por trás da status bar.
- [ ] Listas horizontais não são cortadas pelo padding da página.
- [ ] Scrollbars aparecem nas plataformas certas sem duplicação no desktop.
- [ ] Scrollables têm padding inferior correto sem cortar conteúdo com `SafeArea`.
- [ ] Tabs e bottom navigation respondem a reselect e mantêm o item selecionado visível.
- [ ] Números são formatados para humanos e usam tabular figures quando mudam.
- [ ] O app nunca mostra `null`, string vazia ou `"null"` para o usuário.
- [ ] Seleção de texto, cursor e handles combinam com a marca.
- [ ] Flutter Web tem progresso inicial, título por rota e Open Graph com imagem correta.
- [ ] Links sociais abrem apps externos quando possível.
- [ ] Downloads usam share sheet quando o objetivo é salvar ou compartilhar o arquivo.
- [ ] Transições, date pickers, sheets, modais e comportamento de voltar respeitam a plataforma.
- [ ] Versão do app, changelog e notificações por timezone foram considerados.
