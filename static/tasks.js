angular
  .module('employeeTasks', [])
  .controller('TaskCtrl', TaskCtrl);

function TaskCtrl($scope, $http) {
  $scope.tasks = [];
  $scope.state = '';

  $http.get('./tasks.json').
    success(function(data) {
      console.log(data);
      $scope.tasks = data;
    }).
    error(function(data, status, headers, config) {
      console.log(data);
    });

  $scope.save = function(newVal, oldVal) {
    console.log(newVal);
    console.log($scope.tasks);
    $http.post('./tasks', {tasks: $scope.tasks}).
      success(function(data) {
        console.log(data);
      }).
      error(function(data, status, headers, config) {
        console.log(data);
      });
  };

}
