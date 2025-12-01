/// Scouting Template Model
/// Predefined templates for scouting reports
class ScoutingTemplate {
  final String title;
  final String description;

  ScoutingTemplate(this.title, this.description);
}

/// Available scouting templates
final List<ScoutingTemplate> scoutingTemplates = [
  ScoutingTemplate(
    'Attacking Template',
    '⚽ Offensive Attributes:\n'
        '- Speed & acceleration\n'
        '- Dribbling ability\n'
        '- Ball control under pressure\n'
        '- Finishing efficiency\n'
        '- Passing in final third\n'
        '- Movement off the ball\n'
        '\n📌 Summary:\n',
  ),
  ScoutingTemplate(
    'Defensive Template',
    '🛡 Defensive Attributes:\n'
        '- Tackling timing\n'
        '- Positioning\n'
        '- 1v1 defending\n'
        '- Strength & aggression\n'
        '- Interceptions\n'
        '- Aerial duels\n'
        '\n📌 Summary:\n',
  ),
  ScoutingTemplate(
    'Talent Profile Template',
    '🌟 Talent Profile:\n'
        '- Technical strengths\n'
        '- Weaknesses\n'
        '- Physical attributes\n'
        '- Football IQ\n'
        '- Coachability\n'
        '- Long-term potential\n'
        '\n📌 Summary:\n',
  ),
];
