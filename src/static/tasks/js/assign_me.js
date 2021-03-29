window.onload = function (event) {
  const assigneeSelect = document.getElementById('id_assignee');
  const assignmeButton = document.getElementById('assignme');
  if (!!!assignmeButton) return;

  const userIdInput = document.getElementById('login_user_id');
  console.log('userId:', userIdInput);

  const getUserOptionIndex = (userId) => {
    const options = document.querySelectorAll('#id_assignee > option');
    for (const index in options) {
      const option = options[index];
      if (option.value === userId) return index;
    }
    console.log('no matching');
    return -1;
  };

  assignmeButton.onclick = (event) => {
    event.preventDefault();

    if (!!!userIdInput) return;
    const userId = userIdInput.value;

    const index = getUserOptionIndex(userId);
    if (index >= 0) assigneeSelect.selectedIndex = index;
  };
};
