function TodoCtrl($scope) {
  $scope.state = "nada"
  $scope.todos = [{
    task: 'Task 1',
    done: false
  }, {
    task: 'Task 2',
    done: false
  }, {
    task: 'Task 3',
    done: false
  }];
  $scope.getTotalTodos = function() {
    return $scope.todos.length;
  };
  $scope.getState = function(index) {
    $scope.state = "Todo #" + index + " was clicked"
  }


};
