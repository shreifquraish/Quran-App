import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../providers/app_provider.dart';

class TajweedScreen extends StatefulWidget {
  const TajweedScreen({super.key});

  @override
  State<TajweedScreen> createState() => _TajweedScreenState();
}

class _TajweedScreenState extends State<TajweedScreen> {
  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final dark = app.isDarkMode;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: AppTheme.gradientBackground(dark: dark),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_forward_rounded),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'قواعد التجويد',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              'تعلم أحكام تلاوة القرآن الكريم',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _TajweedRuleCard(
                        title: 'النون الساكنة والتنوين',
                        description: 'أحكام النون الساكنة والتنوين: الإظهار، الإدغام، الإقلاب، الإخفاء',
                        icon: Icons.text_fields_rounded,
                        dark: dark,
                        onTap: () => _showRuleDetail(context, 'النون الساكنة والتنوين', '''
أحكام النون الساكنة والتنوين:

تأتي النون الساكنة (نْ) أو التنوين (ــٌ ، ــٍ ، ــً) قبل حروف الهجاء، وتنقسم إلى أربعة أحكام:

• الإظهار: النطق بالحرفين بوضوح دون غنة. وحروفه ستة: (أ، هـ، ع، ح، غ، خ).

• الإدغام: دمج حرف بآخر ليصبحا حرفاً واحداً مشدداً. وحروفه ستة مجموعة في كلمة (يرملون).

• الإقلاب: قلب النون الساكنة أو التنوين إلى حرف "ميم" مخفاة مع غنة، وذلك إذا جاء بعدها حرف الباء (ب).

• الإخفاء: النطق بالحرف بصفة بين الإظهار والإدغام مع غنة. وحروفه هي باقي الحروف البالغ عددها 15 حرفاً.
                        '''),
                      ),
                      const SizedBox(height: 12),
                      _TajweedRuleCard(
                        title: 'الميم الساكنة',
                        description: 'أحكام الميم الساكنة: الإخفاء الشفوي، الإدغام الشفوي، الإظهار الشفوي',
                        icon: Icons.text_format_rounded,
                        dark: dark,
                        onTap: () => _showRuleDetail(context, 'الميم الساكنة', '''
أحكام الميم الساكنة (مْ):

تتعلق بالميم الساكنة إذا وقعت قبل حروف الهجاء وتنقسم إلى ثلاثة أحكام:

• الإخفاء الشفوي: إذا أتى بعدها حرف الباء (ب) مع الغنة (مثل: يعتصم بالله).

• الإدغام الشفوي: إذا أتى بعدها ميم أخرى متحركة (مثل: كم من).

• الإظهار الشفوي: إذا أتى بعدها باقي الحروف الهجائية (مثل: أنعمت).
                        '''),
                      ),
                      const SizedBox(height: 12),
                      _TajweedRuleCard(
                        title: 'اللام الساكنة',
                        description: 'أحكام اللام الساكنة: القمرية والشمسية',
                        icon: Icons.text_rotate_up_rounded,
                        dark: dark,
                        onTap: () => _showRuleDetail(context, 'اللام الساكنة', '''
أحكام اللام الساكنة:

1. اللام القمرية:
- تظهر مع 14 حرفاً: ا ب غ ح خ ع ف ق ك م هـ ي
- مثال: (الرحمن)، (البر)، (الغفور)، (الحكيم)، (الخبير)، (العليم)، (الفتاح)، (القدوس)، (الكريم)، (المجيد)، (المهيمن)، (الهادي)، (الرؤوف)

2. اللام الشمسية:
- تدغم مع 14 حرفاً: ت ث د ذ ر ز س ش ص ض ط ظ ل ن
- مثال: (التائبون)، (الثواب)، (الداعين)، (الذاكرين)، (الراكعين)، (الزاهدين)، (الساجدين)، (الشاكرين)، (الصابرين)، (الضالين)، (الطائعين)، (الظالمين)، (اللطيف)، (النصير)
                        '''),
                      ),
                      const SizedBox(height: 12),
                      _TajweedRuleCard(
                        title: 'المخارج والصفات',
                        description: 'مخارج الحروف وصفاتها الأساسية',
                        icon: Icons.record_voice_over_rounded,
                        dark: dark,
                        onTap: () => _showRuleDetail(context, 'المخارج والصفات', '''
مخارج الحروف:

1. الجوف: وتخرج منه حروف المد الثلاثة: الواو الساكنة المضموم ما قبلها، والألف الساكنة المفتوح ما قبلها، والياء الساكنة المكسور ما قبلها.

2. الحلق: وتخرج منه ستة حروف: الهمزة، الهاء، العين، الحاء، الغين، الخاء.

3. اللسان: وتخرج منه معظم الحروف.

4. الشفتان: وتخرج منهما حرفا الباء والميم مع الواو.

5. الخيشوم: وتخرج منه الغنة.

صفات الحروف:
- صفات لازمه: الجهر، الشدة، الرخاوة، الاستعلاء، الاستفال، الإطباق، الانفتاح، الذلاقة، الصفير، القلقلة، اللين، الانحراف، التكرير، التفشي، الخفاء، الغنة.
- صفات عارضة: التفخيم، الترقيق، الإدغام، الإظهار، القلقلة.
                        '''),
                      ),
                      const SizedBox(height: 12),
                      _TajweedRuleCard(
                        title: 'أحكام المدود',
                        description: 'أنواع المدود: الطبيعي، المتصل، المنفصل، العارض للسكون، اللازم',
                        icon: Icons.timeline_rounded,
                        dark: dark,
                        onTap: () => _showRuleDetail(context, 'أحكام المدود', '''
أحكام المدود:

المد هو إطالة الصوت بأحد حروف المد الثلاثة (الألف، الواو، الياء). ينقسم إلى قسمين رئيسيين:

• المد الأصلي (الطبيعي): لا يتوقف على سبب (همز أو سكون)، ومقداره حركتان.

• المد الفرعي: يتوقف على سبب (الهمز أو السكون)، ومن أنواعه:

- المد الواجب المتصل: أن يأتي حرف المد وبعده همز في كلمة واحدة، ويمد (4 أو 5 حركات).

- المد الجائز المنفصل: أن يأتي حرف المد في نهاية كلمة والهمز في بداية الكلمة التي تليها.
                        '''),
                      ),
                      const SizedBox(height: 12),
                      _TajweedRuleCard(
                        title: 'أحكام القلقلة',
                        description: 'حروف القلقلة وكيفية نطقها',
                        icon: Icons.vibration_rounded,
                        dark: dark,
                        onTap: () => _showRuleDetail(context, 'أحكام القلقلة', '''
أحكام القلقلة:

اهتزاز الحرف الساكن في مخرجه حتى يُسمع له نبرة قوية. حروفها خمسة مجموعة في كلمة (قطب جد):

• القاف (ق)
• الطاء (ط)
• الباء (ب)
• الجيم (ج)
• الدال (د)

تأتي القلقلة في ثلاثة مواضع:
1. في وسط الكلمة
2. في آخر الكلمة مع السكون العارض
3. في آخر الكلمة مع السكون الأصلي
                        '''),
                      ),
                      const SizedBox(height: 12),
                      _TajweedRuleCard(
                        title: 'الوقف والابتداء',
                        description: 'قواعد الوقف على رؤوس الآيات والابتداء بها',
                        icon: Icons.stop_circle_rounded,
                        dark: dark,
                        onTap: () => _showRuleDetail(context, 'الوقف والابتداء', '''
قواعد الوقف والابتداء:

1. الوقف التام:
- يكون على رأس الآية أو عند انتهاء المعنى
- يجوز الابتداء بما قبله أو بما بعده
- مثال: (مالك يوم الدين) تام

2. الوقف الكافي:
- يكون على كلمة يحسن الوقف عليها
- يجوز الابتداء بما بعدها
- مثال: (الحمد) كافي

3. الوقف الحسن:
- يكون على كلمة لا يخل بالمعنى
- يجوز الابتداء بما بعدها
- مثال: (لله) حسن

4. الوقف القبيح:
- يكون على كلمة يخل بالمعنى
- لا يجوز الابتداء بما بعدها
- مثال: (لا إله) قبيح

5. الابتداء:
- يجب أن يكون بكلمة تامة المعنى
- يفضل الابتداء ببسم الله الرحمن الرحيم
                        '''),
                      ),
                      const SizedBox(height: 12),
                      _TajweedRuleCard(
                        title: 'القراءة الصحيحة',
                        description: 'كيفية القراءة الصحيحة للقرآن الكريم',
                        icon: Icons.mic_rounded,
                        dark: dark,
                        onTap: () => _showRuleDetail(context, 'القراءة الصحيحة', '''
كيفية القراءة الصحيحة للقرآن الكريم:

1. الطهارة:
- يجب أن يكون القارئ على طهارة من الحدث الأكبر والأصغر
- التطيب وتنظيف الفم قبل القراءة

2. الاستعاذة والبسملة:
- البدء بالاستعاذة: أعوذ بالله من الشيطان الرجيم
- البسملة في بداية كل سورة إلا التوبة
- الجهر بالاستعاذة والبسملة في القراءة الجهرية

3. الترتيل:
- القراءة بتأنٍ وتمهل مع مراعاة أحكام التجويد
- تبيين الحروف وإخراجها من مخارجها الصحيحة
- مراعاة الوقوف المكتوبة في المصحف

4. الخشوع:
- حضور القلب وتدبر معاني الآيات
- القراءة بخشوع وتأثر بمعاني القرآن
- التفكر في عظمة الله من خلال آياته

5. التدبر:
- فهم معاني الآيات والتفكر فيها
- تطبيق ما في القرآن من أحكام وآداب
- السؤال عن معاني ما لا يفهمه القارئ

6. الأدب مع القرآن:
- عدم القراءة في أماكن غير لائقة
- احترام المصحف وعدم وضعه في الأرض
- لمس المصحف بالطهارة
                        '''),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRuleDetail(BuildContext context, String title, String content) {
    final app = context.watch<AppProvider>();
    final dark = app.isDarkMode;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Container(
              decoration: AppTheme.gradientBackground(dark: dark),
              child: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_forward_rounded),
                          ),
                          Expanded(
                            child: Text(
                              title,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Container(
                            decoration: AppTheme.cardDecoration(dark: dark),
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              content,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    height: 2,
                                    fontSize: 16,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TajweedRuleCard extends StatelessWidget {
  const _TajweedRuleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.dark,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration(dark: dark),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        AppColors.accent.withOpacity(0.35),
                        AppColors.primaryLight.withOpacity(0.5),
                      ],
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.accent,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
