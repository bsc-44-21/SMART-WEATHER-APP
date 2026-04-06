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
      } else if (normalizedCrop.contains('tomato')) {
      return [
        {
          'dap': 14,
          'title': 'Staking',
          'body': 'Support your Tomato plants in "$plotName" with stakes to keep fruit off the ground.',
        },
        {
          'dap': 35,
          'title': 'Pruning/Suckering',
          'body': 'Remove side shoots on your Tomato plants in "$plotName" to improve fruit quality.',
        },
        {
          'dap': 90,
          'title': 'Harvesting',
          'body': 'First harvest for Tomatos in "$plotName". Pick when fruit starts turning red.',
        },
      ];
    } else if (normalizedCrop.contains('nut')) {
      return [
        {
          'dap': 14,
          'title': 'Weeding',
          'body': 'Weed your G/Nuts in "$plotName" and loosen soil to help pods penetrate (pegging).',
        },
        {
          'dap': 60,
          'title': 'Earthing Up',
          'body': 'Weed your G/Nuts in "$plotName" and loosen soil to help pods penetrate (pegging).',
        },
        {
          'dap': 110,
          'title': 'Harvesting',
          'body': 'Check your G/Nuts maturity in "$plotName". Pull a sample to see if seeds are dark.',
        },
      ];
    }
    
    return [];
  }
}
