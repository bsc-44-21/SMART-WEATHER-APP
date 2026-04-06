class CropMilestoneData {
    static List<Map<String, dynamic>> getMilestonesForCrop(String cropName, String plotName) {
    String normalizedCrop = cropName.toLowerCase().trim();

    if (normalizedCrop.contains('maize')) {
      return [
        {
          'dap': 21,
          'title': 'First Weeding',
          'body': 'Your Maize plot "$plotName" is 3 weeks old. Start weeding to prevent nutrient competition.',
        },
         {
          'dap': 45,
          'title': 'Top Dressing (Urea)',
          'body': 'Time to apply nitrogen fertilizer to "$plotName" for optimal stalk and leaf growth.',
        },
        {
          'dap': 120,
          'title': 'Harvesting',
          'body': 'Your Maize at "$plotName" should be reaching maturity. Check for dry husks.',
        },
      ];
}