angular
  .module('employeeTasks', ['ngSanitize'])
  .controller('TaskCtrl', TaskCtrl);

function TaskCtrl($scope, $http, $timeout){
  $scope.tasks = [];
  $scope.state = '';
  $scope.saveErrorText = "Oops, something is on fire and save failed. Please try again later."
  $scope.getErrorText = "Oops, something is on fire and your tasks are not available. Please try again later."

  $http.get('./tasks.json').success(function(data){
    $scope.tasks = data;
  }).error(function(data, status, headers, config){
    $scope.getFailed = true;

    $timeout(function(){
      $scope.getFailed = false;
    }, 3000)
  });

  $scope.save = function(){
    $http.post('./tasks', {tasks: $scope.tasks}).success(function(data){
      console.log("reload tasks to kep things in sync");
      $scope.tasks = data;
    }).error(function(data, status, headers, config){
      console.log(data, status, headers, config)
      $scope.saveFailed = true;
      $timeout(function(){
        $scope.saveFailed = false;
      }, 3000)
    });
  };

}
