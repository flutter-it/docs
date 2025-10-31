// ignore_for_file: missing_function_body, unused_element
// Enable multiple registrations first
getIt.enableRegisteringMultipleInstancesOfOneType();

getIt.registerSingleton<ApiClient>(ProdApiClient(), instanceName: 'prod');
getIt.registerSingleton<ApiClient>(DevApiClient(), instanceName: 'dev');