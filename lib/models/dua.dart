class DuaCategory {
  const DuaCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.duas,
  });

  final String id;
  final String name;
  final String icon;
  final List<Dua> duas;
}

class Dua {
  const Dua({
    required this.id,
    required this.title,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    this.reference,
  });

  final String id;
  final String title;
  final String arabic;
  final String transliteration;
  final String translation;
  final String? reference;
}

const duaCategories = [
  DuaCategory(
    id: 'morning',
    name: 'أذكار الصباح',
    icon: '☀️',
    duas: [
      Dua(
        id: 'morning_1',
        title: 'أذكار الصباح',
        arabic: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لاَ إِلَهَ إلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، رَبَّنَا أَسْأَلُكَ خَيْرَ مَا فِي هَذَا الْيَوْمِ وَخَيْرَ مَا بَعْدَهُ، وَأَعُوذُ بِكَ مِنْ شَرِّ مَا فِي هَذَا الْيَوْمِ وَشَرِّ مَا بَعْدَهُ، رَبَّنَا أَعُوذُ بِكَ مِنَ الْكَسَلِ وَسُوءِ الْكِبَرِ، رَبَّنَا أَعُوذُ بِكَ مِنْ عَذَابٍ فِي النَّارِ وَعَذَابٍ فِي الْقَبْرِ',
        transliteration: 'Asbahna wa asbahal mulku lillah, walhamdu lillah, la ilaha illallah wahdahu la sharika lah, lahul mulku wa lahul hamdu wa huwa ala kulli shayin qadir, Rabbana asaluka khayra ma fi hadhay yawmi wa khayra ma ba\'dahu, wa a\'udhu bika min sharri ma fi hadhay yawmi wa sharri ma ba\'dahu, Rabbana a\'udhu bika minal kasali wa su\'il kibari, Rabbana a\'udhu bika min \'adhabin fin nari wa \'adhabin fil qabri',
        translation: 'أصبحنا وأصبح الملك لله، والحمد لله، لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير، ربنا أسألك خير ما في هذا اليوم وخير ما بعده، وأعوذ بك من شر ما في هذا اليوم وشر ما بعده، ربنا أعوذ بك من الكسل وسوء الكبر، ربنا أعوذ بك من عذاب في النار وعذاب في القبر',
        reference: 'مسلم',
      ),
      Dua(
        id: 'morning_2',
        title: 'الاستغفار',
        arabic: 'أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ الَّذِي لاَ إِلَهَ إلاَّ هُوَ الْحَيُّ الْقَيُّومُ وَأَتُوبُ إِلَيْهِ',
        transliteration: 'Astaghfirullahal \'azimalladhi la ilaha illa huwal hayyul qayyumu wa atubu ilayh',
        translation: 'أستغفر الله العظيم الذي لا إله إلا هو الحي القيوم وأتوب إليه',
        reference: 'البخاري',
      ),
      Dua(
        id: 'morning_3',
        title: 'حصن المسلم',
        arabic: 'بِسْمِ اللَّهِ الَّذِي لاَ يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلاَ فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
        transliteration: 'Bismillahilladhi la yadurru ma\'asmihi shayun fil ardi wa fis sama\'i wa huwas sami\'ul \'alim',
        translation: 'بسم الله الذي لا يضر مع اسمه شيء في الأرض ولا في السماء وهو السميع العليم', 
        reference: 'أبو داود والترمذي',
      ),
    ],
  ),
  DuaCategory(
    id: 'sleep',
    name: 'أذكار النوم',
    icon: '🌙',
    duas: [
      Dua(
        id: 'sleep_1',
        title: 'أذكار النوم',
        arabic: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
        transliteration: 'Bismika Allahumma amutu wa ahya',
        translation: 'باسمك اللهم أموت وأحيا',
        reference: 'البخاري',
      ),
      Dua(
        id: 'sleep_2',
        title: 'التوحيد',
        arabic: 'اللَّهُمَّ أَسْلَمْتُ نَفْسِي إِلَيْكَ، وَفَوَّضْتُ أَمْرِي إِلَيْكَ، وَوَجَّهْتُ وَجْهِي إِلَيْكَ، وَأَلْجَأْتُ ظَهْرِي إِلَيْكَ، رَغْبَةً وَرَهْبَةً إِلَيْكَ، لاَ مَلْجَأَ وَلاَ مَنْجَا مِنْكَ إِلاَّ إِلَيْكَ، آمَنْتُ بِكِتَابِكَ الَّذِي أَنْزَلْتَ وَبِنَبِيِّكَ الَّذِي أَرْسَلْتَ',
        transliteration: 'Allahumma aslamtu nafsi ilayk, wa fawwadtu amri ilayk, wa wajjahtu wajhi ilayk, wa alja\'tu zahri ilayk, raghbatan wa rahbatan ilayk, la malja\'a wa la manja minka illa ilayk, amantu bikitabikalladhi anzalta wa binabiyyikalladhi arsalta',
        translation: 'اللهم أسلمت نفسي إليك، وفوضت أمري إليك، ووجهت وجهي إليك، وألجأت ظهري إليك، رغبة ورهبة إليك، لا ملجأ ولا منجا منك إلا إليك، آمنت بكتابك الذي أنزلت وبنبيك الذي أرسلت',
        reference: 'البخاري ومسلم',
      ),
      Dua(
        id: 'sleep_3',
        title: 'آية الكرسي',
        arabic: 'اللَّهُ لاَ إِلَهَ إلاَّ هُوَ الْحَيُّ الْقَيُّومُ لاَ تَأْخُذُهُ سِنَةٌ وَلاَ نَوْمٌ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إلاَّ بِإِذْنِهِ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ وَلاَ يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إلاَّ بِمَا شَاءَ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ وَلاَ يَئُودُهُ حِفْظُهُمَا وَهُوَ الْعَلِيُّ الْعَظِيمُ',
        transliteration: 'Allahu la ilaha illa huwal hayyul qayyum, la taakhudhuhu sinatun wa la nawm, lahu ma fis samawati wa ma fil ard, man tha alladhi yashfa\'u indahu illa bi iznih, ya\'lamu ma bayna aydihim wa ma khalfahum, wa la yuhituna bishayin min ilmihi illa bima sha, wasi\'a kursiyuhus samawati wal ard, wa la yauduhu hifdhuhuma wa huwal aliyyul azim',
        translation: 'الله لا إله إلا هو الحي القيوم لا تأخذه سنة ولا نوم له ما في السماوات وما في الأرض من ذا الذي يشفع عنده إلا بإذنه يعلم ما بين أيديهم وما خلفهم ولا يحيطون بشيء من علمه إلا بما شاء وسع كرسيه السماوات والأرض ولا يؤوده حفظهما وهو العلي العظيم',
        reference: 'البخاري',
      ),
      Dua(
        id: 'sleep_4',
        title: 'المعوذات',
        arabic: 'قُلْ هُوَ اللَّهُ أَحَدٌ، قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ، قُلْ أَعُوذُ بِرَبِّ النَّاسِ',
        transliteration: 'Qul huwallahu ahad, Qul a\'udhu birabbil falak, Qul a\'udhu birabbin nas',
        translation: 'قل هو الله أحد، قل أعوذ برب الفلق، قل أعوذ برب الناس',
        reference: 'البخاري ومسلم',
      ),
    ],
  ),
  DuaCategory(
    id: 'waking',
    name: 'أذكار الاستيقاظ',
    icon: '⏰',
    duas: [
      Dua(
        id: 'waking_1',
        title: 'دعاء الاستيقاظ',
        arabic: 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
        transliteration: 'Alhamdu lillahilladhi ahyana ba\'da ma amatana wa ilayhin nushur',
        translation: 'الحمد لله الذي أحيانا بعد ما أماتنا وإليه النشور',
        reference: 'البخاري',
      ),
      Dua(
        id: 'waking_2',
        title: 'دعاء النهوض',
        arabic: 'الْحَمْدُ لِلَّهِ الَّذِي رَدَّ عَلَيَّ رُوحِي وَأَذِنَ لِي بِذِكْرِهِ وَشُكْرِهِ',
        transliteration: 'Alhamdu lillahilladhi radda \'alayya ruhi wa adhina li bidhikrihi wa shukrihi',
        translation: 'الحمد لله الذي رد علي روحي وأذن لي بذكره وشكره',
        reference: 'الترمذي',
      ),
    ],
  ),
  DuaCategory(
    id: 'evening',
    name: 'أذكار المساء',
    icon: '🌙',
    duas: [
      Dua(
        id: 'evening_1',
        title: 'أذكار المساء',
        arabic: 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لاَ إِلَهَ إلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، رَبَّنَا أَسْأَلُكَ خَيْرَ مَا فِي هَذِهِ اللَّيْلَةِ وَخَيْرَ مَا بَعْدَهَا، وَأَعُوذُ بِكَ مِنْ شَرِّ مَا فِي هَذِهِ اللَّيْلَةِ وَشَرِّ مَا بَعْدَهَا، رَبَّنَا أَعُوذُ بِكَ مِنَ الْكَسَلِ وَسُوءِ الْكِبَرِ، رَبَّنَا أَعُوذُ بِكَ مِنْ عَذَابٍ فِي النَّارِ وَعَذَابٍ فِي الْقَبْرِ',
        transliteration: 'Amsayna wa amsal mulku lillah, walhamdu lillah, la ilaha illallah wahdahu la sharika lah, lahul mulku wa lahul hamdu wa huwa ala kulli shayin qadir, Rabbana asaluka khayra ma fi hadhihil laylah wa khayra ma ba\'daha, wa a\'udhu bika min sharri ma fi hadhihil laylah wa sharri ma ba\'daha, Rabbana a\'udhu bika minal kasali wa su\'il kibari, Rabbana a\'udhu bika min \'adhabin fin nari wa \'adhabin fil qabri',
        translation: 'أمسينا وأمسى الملك لله، والحمد لله، لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير، ربنا أسألك خير ما في هذه الليلة وخير ما بعدها، وأعوذ بك من شر ما في هذه الليلة وشر ما بعدها، ربنا أعوذ بك من الكسل وسوء الكبر، ربنا أعوذ بك من عذاب في النار وعذاب في القبر',
        reference: 'مسلم',
      ),
      Dua(
        id: 'evening_2',
        title: 'آية الكرسي',
        arabic: 'اللَّهُ لاَ إِلَهَ إلاَّ هُوَ الْحَيُّ الْقَيُّومُ لاَ تَأْخُذُهُ سِنَةٌ وَلاَ نَوْمٌ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إلاَّ بِإِذْنِهِ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ وَلاَ يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إلاَّ بِمَا شَاءَ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ وَلاَ يَئُودُهُ حِفْظُهُمَا وَهُوَ الْعَلِيُّ الْعَظِيمُ',
        transliteration: 'Allahu la ilaha illa huwal hayyul qayyum, la taakhudhuhu sinatun wa la nawm, lahu ma fis samawati wa ma fil ard, man tha alladhi yashfa\'u indahu illa bi iznih, ya\'lamu ma bayna aydihim wa ma khalfahum, wa la yuhituna bishayin min ilmihi illa bima sha, wasi\'a kursiyuhus samawati wal ard, wa la yauduhu hifdhuhuma wa huwal aliyyul azim',
        translation: 'الله لا إله إلا هو الحي القيوم لا تأخذه سنة ولا نوم له ما في السماوات وما في الأرض من ذا الذي يشفع عنده إلا بإذنه يعلم ما بين أيديهم وما خلفهم ولا يحيطون بشيء من علمه إلا بما شاء وسع كرسيه السماوات والأرض ولا يؤوده حفظهما وهو العلي العظيم',
        reference: 'البخاري',
      ),
    ],
  ),
  DuaCategory(
    id: 'prophets',
    name: 'أدعية الأنبياء',
    icon: '🕌',
    duas: [
      Dua(
        id: 'prophet_1',
        title: 'دعاء سيدنا يوسف',
        arabic: 'رَبِّ قَدْ آتَيْتَنِي مِنَ الْمُلْكِ وَعَلَّمْتَنِي مِنْ تَأْوِيلِ الأَحَادِيثِ فَاطِرَ السَّمَاوَاتِ وَالأَرْضِ أَنْتَ وَلِيِّي فِي الدُّنْيَا وَالآخِرَةِ تَوَفَّنِي مُسْلِماً وَأَلْحِقْنِي بِالصَّالِحِينَ',
        transliteration: 'Rabbi qad ataytan minal mulki wa allamtani min ta\'wilil ahadith, fatiras samawati wal ard, anta waliyyi fid dunya wal akhirah, tawaffani musliman wa alhiqis salihin',
        translation: 'رب قد آتيتني من الملك وعلمتني من تأويل الأحاديث فاطر السماوات والأرض أنت وليي في الدنيا والآخرة توفني مسلماً وألحقني بالصالحين',
        reference: 'يوسف: 101',
      ),
      Dua(
        id: 'prophet_2',
        title: 'دعاء سيدنا إبراهيم',
        arabic: 'رَبَّنَا تَقَبَّلْ مِنَّا إِنَّكَ أَنْتَ السَّمِيعُ الْعَلِيمُ',
        transliteration: 'Rabbana taqabbal minna innaka antas sami\'ul alim',
        translation: 'ربنا تقبل منا إنك أنت السميع العليم',
        reference: 'البقرة: 127',
      ),
      Dua(
        id: 'prophet_3',
        title: 'دعاء سيدنا موسى',
        arabic: 'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي وَاحْلُلْ عُقْدَةً مِنْ لِسَانِي يَفْقَهُوا قَوْلِي',
        transliteration: 'Rabbi ishrah li sadri wa yassir li amri, wahlul \'uqdatan min lisani yafqahu qawli',
        translation: 'رب اشرح لي صدري ويسر لي أمري واحلل عقدة من لساني يفقهوا قولي',
        reference: 'طه: 25-28',
      ),
      Dua(
        id: 'prophet_4',
        title: 'دعاء سيدنا عيسى',
        arabic: 'إِنَّ اللَّهَ رَبِّي وَرَبُّكُمْ فَاعْبُدُوهُ هَذَا صِرَاطٌ مُسْتَقِيمٌ',
        transliteration: 'Innallaha rabbi wa rabbukum fa\'buduh, hadha siratun mustaqim',
        translation: 'إن الله ربي وربكم فاعبدوه هذا صراط مستقيم',
        reference: 'آل عمران: 51',
      ),
      Dua(
        id: 'prophet_5',
        title: 'دعاء سيدنا محمد ﷺ',
        arabic: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْهُدَى وَالتُّقَى وَالْعَفَافَ وَالْغِنَى',
        transliteration: 'Allahumma inni as\'alukal hada wat taqa wal \'afafa wal ghina',
        translation: 'اللهم إني أسألك الهدى والتقى والعفاف والغنى',
        reference: 'مسلم',
      ),
    ],
  ),
  DuaCategory(
    id: 'general',
    name: 'أدعية عامة',
    icon: '🤲',
    duas: [
      Dua(
        id: 'general_1',
        title: 'دعاء السفر',
        arabic: 'اللَّهُمَّ إِنَّا نَسْأَلُكَ فِي سَفَرِنَا هَذَا الْبِرَّ وَالتَّقْوَى، وَمِنَ الْعَمَلِ مَا تَرْضَى، اللَّهُمَّ هَوِّنْ عَلَيْنَا سَفَرَنَا هَذَا وَاطْوِ عَنَّا بُعْدَهُ، اللَّهُمَّ أَنْتَ الصَّاحِبُ فِي السَّفَرِ، وَالْخَلِيفَةُ فِي الأَهْلِ، اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ وَعْثَاءِ السَّفَرْ، وَكَآبَةِ الْمَنْظَرِ، وَسُوءِ الْمُنْقَلَبِ فِي الْمَالِ وَالأَهْلِ',
        transliteration: 'Allahumma inna nasaluka fi safarina hadhal birra wat taqwa, wa minal \'amali ma tarza, Allahumma hawwin \'alayna safarana hadha watwi \'anna bu\'dahu, Allahumma antas sahibu fis safari, wal khalifatu fil ahli, Allahumma inni a\'udhu bika min wa\'thais safari, wa ka\'abatil manzari, wa su\'il munqalabi fil mali wal ahli',
        translation: 'اللهم إنا نسألك في سفرنا هذا البر والتقى، ومن العمل ما ترضى، اللهم هون علينا سفرنا هذا واطو عنا بعده، اللهم أنت الصاحب في السفر، والخليفة في الأهل، اللهم إني أعوذ بك من وعثاء السفر، وكآبة المنظر، وسوء المنقلب في المال والأهل',
        reference: 'مسلم',
      ),
      Dua(
        id: 'general_2',
        title: 'دعاء الهم والغم',
        arabic: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ الْهَمِّ وَالْحُزْنِ، وَأَعُوذُ بِكَ مِنْ الْعَجْزِ وَالْكَسَلِ، وَأَعُوذُ بِكَ مِنَ الْجُبْنِ وَالْبُخْلِ، وَأَعُوذُ بِكَ مِنْ غَلَبَةِ الدَّيْنِ وَقَهْرِ الرِّجَالِ',
        transliteration: 'Allahumma inni a\'udhu bika minal hammi wal hazan, wa a\'udhu bika minal \'ajzi wal kasali, wa a\'udhu bika minal jubni wal bukhli, wa a\'udhu bika min ghalabat dayni wa qahri rijal',
        translation: 'اللهم إني أعوذ بك من الهم والحزن، وأعوذ بك من العجز والكسل، وأعوذ بك من الجبن والبخل، وأعوذ بك من غلبة الدين وقهر الرجال',
        reference: 'البخاري',
      ),
      Dua(
        id: 'general_3',
        title: 'دعاء الكرب',
        arabic: 'لاَ إِلَهَ إِلاَّ اللَّهُ الْعَظِيمُ الْحَلِيمُ، لاَ إِلَهَ إِلاَّ اللَّهُ رَبُّ الْعَرْشِ الْعَظِيمِ، لاَ إِلَهَ إِلاَّ اللَّهُ رَبُّ السَّمَاوَاتِ وَرَبُّ الأَرْضِ وَرَبُّ الْعَرْشِ الْكَرِيمِ',
        transliteration: 'La ilaha illallahul \'azimul halim, la ilaha illallahu rabbul \'arshil \'azim, la ilaha illallahu rabbus samawati wa rabbul ard wa rabbul \'arshil karim',
        translation: 'لا إله إلا الله العظيم الحليم، لا إله إلا الله رب العرش العظيم، لا إله إلا الله رب السماوات ورب الأرض ورب العرش الكريم',
        reference: 'البخاري ومسلم',
      ),
      Dua(
        id: 'general_4',
        title: 'صلاة الاستخارة',
        arabic: 'اللَّهُمَّ إِنِّي أَسْتَخِيرُكَ بِعِلْمِكَ، وَأَسْتَقْدِرُكَ بِقُدْرَتِكَ، وَأَسْأَلُكَ مِنْ فَضْلِكَ الْعَظِيمِ فَإِنَّكَ تَقْدِرُ وَلاَ أَقْدِرُ، وَتَعْلَمُ وَلاَ أَعْلَمُ، وَأَنْتَ عَلاَّمُ الْغُيُوبِ، اللَّهُمَّ إِنْ كُنْتَ تَعْلَمُ أَنَّ هَذَا الأَمْرَ خَيْرٌ لِي فِي دِينِي وَمَعَاشِي وَعَاقِبَةِ أَمْرِي فَاقْدُرْهُ لِي وَيَسِّرْهُ لِي ثُمَّ بَارِكْ لِي فِيهِ، وَإِنْ كُنْتَ تَعْلَمُ أَنَّ هَذَا الأَمْرَ شَرٌّ لِي فِي دِينِي وَمَعَاشِي وَعَاقِبَةِ أَمْرِي فَاصْرِفْهُ عَنِّي وَاصْرِفْنِي عَنْهُ وَاقْدُرْ لِي الْخَيْرَ حَيْثُ كَانَ ثُمَّ أَرْضِنِي بِهِ',
        transliteration: 'Allahumma inni astakhiruka bi\'ilmika, wa astaqdiruka biqudratika, wa as\'aluka min fadlikal \'azim fa innaka taqdiru wa la aqdir, wa ta\'lamu wa la a\'lam, wa anta \'allamul ghuyub, Allahumma in kunta ta\'lamu anna hadhal amra khayrun li fi dini wa ma\'ashi wa \'aqibati amri faqdurhu li wa yassirhu li thumma barik li fihi, wa in kunta ta\'lamu anna hadhal amra sharrun li fi dini wa ma\'ashi wa \'aqibati amri fasrifhu \'anni wasrifni \'anhu waqdur li alkhayra haythu kana thumma ardini bihi',
        translation: 'اللهم إني أستخيرك بعلمك، وأستقدرك بقدرتك، وأسألك من فضلك العظيم فإنك تقدر ولا أقدر، وتعلم ولا أعلم، وأنت علام الغيوب، اللهم إن كنت تعلم أن هذا الأمر خير لي في ديني ومعاشي وعاقبة أمري فاقدره لي ويسره لي ثم بارك لي فيه، وإن كنت تعلم أن هذا الأمر شر لي في ديني ومعاشي وعاقبة أمري فاصرفه عني واصرفني عنه واقدر لي الخير حيث كان ثم أرضني به',
        reference: 'البخاري',
      ),
      Dua(
        id: 'general_5',
        title: 'دعاء الرخاء',
        arabic: 'اللَّهُمَّ كَمَا حَسَّنْتَ خَلْقِي فَحَسِّنْ خُلُقِي',
        transliteration: 'Allahumma kama hassanta khalqi fa hassassin khuluqi',
        translation: 'اللهم كما حسنت خلقي فحسن خلقي',
        reference: 'أحمد',
      ),
      Dua(
        id: 'general_6',
        title: 'دعاء الرزق',
        arabic: 'اللَّهُمَّ اكْفِنِي بِحَلاَلِكَ عَنْ حَرَامِكَ، وَأَغْنِنِي بِفَضْلِكَ عَمَّنْ سِوَاكَ',
        transliteration: 'Allahumma ikfini bihalalika an haramik, wa aghnini bifaḍlika amman siwak',
        translation: 'اللهم اكفني بحلالك عن حرامك، وأغنني بفضلك عمن سواك',
        reference: 'الترمذي',
      ),
      Dua(
        id: 'general_7',
        title: 'دعاء البركة',
        arabic: 'اللَّهُمَّ بَارِكْ لَنَا فِي أَرْضِنَا وَبَارِكْ لَنَا فِي مَائِنَا وَبَارِكْ لَنَا فِي ثَمَرِنَا وَبَارِكْ لَنَا فِي زَرْعِنَا',
        transliteration: 'Allahumma barik lana fi ardina wa barik lana fi ma\'ina wa barik lana fi thamirina wa barik lana fi zar\'ina',
        translation: 'اللهم بارك لنا في أرضنا وبارك لنا في مائنا وبارك لنا في ثمارنا وبارك لنا في زرعنا',
        reference: 'ابن ماجة',
      ),
      Dua(
        id: 'general_8',
        title: 'دعاء تفريج الكرب',
        arabic: 'اللَّهُمَّ رَحْمَتَكَ أَرْجُو فَلاَ تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ وَأَصْلِحْ لِي شَأْنِي كُلَّهُ لاَ إِلَهَ إِلاَّ أَنْتَ',
        transliteration: 'Allahumma rahmataka arju fala takilni ila nafsi tarfata aynin wa aslih li sha\'ni kullahu la ilaha illa anta',
        translation: 'اللهم رحمتك أرجو فلا تكلني إلى نفسي طرفة عين وأصلح لي شأني كله لا إله إلا أنت',
        reference: 'أبو داود',
      ),
      Dua(
        id: 'general_9',
        title: 'دعاء دخول السوق',
        arabic: 'لاَ إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، يُحْيِي وَيُمِيتُ، وَهُوَ حَيٌّ لاَ يَمُوتُ، بِيَدِهِ الْخَيْرُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
        transliteration: 'La ilaha illallah wahdahu la sharika lah, lahul mulku wa lahul hamdu, yuhyi wa yumit, wa huwa hayyun la yamut, biyadihil khayr, wa huwa ala kulli shayin qadir',
        translation: 'لا إله إلا الله وحده لا شريك له، له الملك وله الحمد، يحيي ويميت، وهو حي لا يموت، بيده الخير، وهو على كل شيء قدير',
        reference: 'الترمذي',
      ),
    ],
  ),
  DuaCategory(
    id: 'healing',
    name: 'أدعية الشفاء',
    icon: '🩺',
    duas: [
      Dua(
        id: 'healing_1',
        title: 'دعاء الشفاء (اللهم رب الناس)',
        arabic: 'اللَّهُمَّ رَبَّ النَّاسِ ، أَذْهِبِ الْبَأْسَ ، وَاشْفِ ، أَنْتَ الشَّافِي لا شِفَاءَ إِلاَّ شِفَاؤُكَ ، شِفَاءً لا يُغَادِرُ سَقَماً.',
        transliteration: 'Allahumma rabban-naas, adhhib al-baas, washfi, anta ash-shaafi la shifaa illa shifauk, shifaa la yughadiru saqaman',
        translation: 'اللهم رب الناس، اذهب البأس واشفِ، أنت الشافي لا شفاء إلا شفاؤك، شفاءً لا يغادر سقماً',
        reference: 'أدعية متداولة',
      ),
      Dua(
        id: 'healing_2',
        title: 'دعاء الشفاء (بسم الله أرقـيكـ)',
        arabic: 'بِسْمِ اللَّهِ أَرْقِيكَ ، مِنْ كُلِّ شَيْءٍ يُؤْذِيكَ، مِنْ شَرِّ كُلِّ نَفْسٍ أَوْ عَيْنِ حَاسِدٍ ، اللَّهُ يَشْفِيكَ ، بِسْمِ اللَّهِ أَرْقِيكَ .',
        transliteration: 'Bismillah arqika, min kulli shay-in yu\'dhika, min sharri kulli nafsin aw \u2018ayni hasidin, Allahu yashfika, bismillah arqika',
        translation: 'بسم الله أرقيك من كل ما يؤذيك، من شر كل نفس أو عين حاسد، الله يشفيك، بسم الله أرقيك',
        reference: 'دعاء مأثور',
      ),
      Dua(
        id: 'healing_3',
        title: 'دعاء الشفاء (اللهم رب الناس - تكرار)',
        arabic: 'اللَّهُمَّ رَبَّ النَّاسِ ، مُذْهِبَ البَأسِ ، اشْفِ أَنتَ الشَّافِي ، لا شافي إِلاَّ أَنْتَ ، شِفاءً لا يُغَادِر سَقَماً.',
        transliteration: 'Allahumma rabban-naas, mudhibal baas, ishfi anta ash-shaafi, la shafi illa anta, shifaa la yughadiru saqaman',
        translation: 'اللهم رب الناس، مذهاب البأس، اشفِ أنت الشافي، لا شافي إلا أنت، شفاءً لا يغادر سقماً',
        reference: 'أدعية مأثورة',
      ),
    ],
  ),
  DuaCategory(
    id: 'quran',
    name: 'أدعية القرآن',
    icon: '📖',
    duas: [
      Dua(
        id: 'quran_1',
        title: 'دعاء سورة البقرة',
        arabic: 'رَبَّنَا لاَ تُؤَاخِذْنَا إِنْ نَسِينَا أَوْ أَخْطَأْنَا، رَبَّنَا وَلاَ تَحْمِلْ عَلَيْنَا إِصْرًا كَمَا حَمَلْتَهُ عَلَى الَّذِينَ مِنْ قَبْلِنَا، رَبَّنَا وَلاَ تُحَمِّلْنَا مَا لاَ طَاقَةَ لَنَا بِهِ، وَاعْفُ عَنَّا وَاغْفِرْ لَنَا وَارْحَمْنَا، أَنْتَ مَوْلاَنَا فَانْصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ',
        transliteration: 'Rabbana la tu\'akhidhanna in nasiyna aw akhta\'na, Rabbana wa la tahmil \'alayna isran kama hamaltahu \'alal ladhina min qablina, Rabbana wa la tuhammilna ma la taqata lana bihi, wa\'fu \'anna waghfir lana warhamna, anta mawlana fansurna \'alal qawmil kafirin',
        translation: 'ربنا لا تؤاخذنا إن نسينا أو أخطأنا، ربنا ولا تحمل علينا إصراً كما حملته على الذين من قبلنا، ربنا ولا تحملنا ما لا طاقة لنا به، واعف عنا واغفر لنا وارحمنا، أنت مولانا فانصرنا على القوم الكافرين',
        reference: 'البقرة: 286',
      ),
      Dua(
        id: 'quran_2',
        title: 'دعاء سورة آل عمران',
        arabic: 'رَبَّنَا لاَ تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا وَهَبْ لَنَا مِنْ لَدُنْكَ رَحْمَةً إِنَّكَ أَنْتَ الْوَهَّابُ',
        transliteration: 'Rabbana la tuzigh qulubana ba\'da idh hadaytana wahab lana min ladunka rahmatan innaka antal wahhab',
        translation: 'ربنا لا تزغ قلوبنا بعد إذ هديتنا وهب لنا من لدنك رحمة إنك أنت الوهاب',
        reference: 'آل عمران: 8',
      ),
      Dua(
        id: 'quran_3',
        title: 'دعاء سورة الكهف',
        arabic: 'رَبَّنَا آتِنَا مِنْ لَدُنْكَ رَحْمَةً وَهَيِّئْ لَنَا مِنْ أَمْرِنَا رَشَدًا',
        transliteration: 'Rabbana atina min ladunka rahmatan wa hayyi\' lana min amrina rashada',
        translation: 'ربنا آتنا من لدنك رحمة وهيئ لنا من أمرنا رشداً',
        reference: 'الكهف: 10',
      ),
      Dua(
        id: 'quran_4',
        title: 'دعاء سورة طه',
        arabic: 'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي وَاحْلُلْ عُقْدَةً مِنْ لِسَانِي يَفْقَهُوا قَوْلِي',
        transliteration: 'Rabbi ishrah li sadri wa yassir li amri wahlul \'uqdatan min lisani yafqahu qawli',
        translation: 'رب اشرح لي صدري ويسر لي أمري واحلل عقدة من لساني يفقهوا قولي',
        reference: 'طه: 25-28',
      ),
    ],
  ),
  DuaCategory(
    id: 'protection',
    name: 'أذكار الحماية',
    icon: '🛡️',
    duas: [
      Dua(
        id: 'protection_1',
        title: 'حصن المسلم',
        arabic: 'بِسْمِ اللَّهِ الَّذِي لاَ يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلاَ فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
        transliteration: 'Bismillahilladhi la yadurru ma\'asmihi shayun fil ardi wa fis sama\'i wa huwas sami\'ul \'alim',
        translation: 'بسم الله الذي لا يضر مع اسمه شيء في الأرض ولا في السماء وهو السميع العليم',
        reference: 'أبو داود والترمذي',
      ),
      Dua(
        id: 'protection_2',
        title: 'الإخلاص والمعوذات',
        arabic: 'قُلْ هُوَ اللَّهُ أَحَدٌ، اللَّهُ الصَّمَدُ، لَمْ يَلِدْ وَلَمْ يُولَدْ، وَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ',
        transliteration: 'Qul huwallahu ahad, Allahus samad, lam yalid wa lam yulad, wa lam yakun lahu kufuwan ahad',
        translation: 'قل هو الله أحد، الله الصمد، لم يلد ولم يولد، ولم يكن له كفواً أحد',
        reference: 'الإخلاص',
      ),
      Dua(
        id: 'protection_3',
        title: 'دعاء الحفظ',
        arabic: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ زَوَالِ نِعْمَتِكَ، وَتَحَوُّلِ عَافِيَتِكَ، وَفُجَاءَةِ نِقْمَتِكَ، وَجَمِيعِ سَخَطِكَ',
        transliteration: 'Allahumma inni a\'udhu bika min zawali ni\'matik, wa tahawwuli \'afiyatik, wa fuja\'ati niqmatik, wa jami\'i sakhatik',
        translation: 'اللهم إني أعوذ بك من زوال نعمتك، وتحول عافيتك، وفجاءة نقمتك، وجميع سخطك',
        reference: 'مسلم',
      ),
    ],
  ),
];
