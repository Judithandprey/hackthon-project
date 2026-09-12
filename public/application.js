// Progressive enhancement: normal Rails forms still work with JavaScript disabled.
const role = document.querySelector('#user_role');
const invitation = document.querySelector('#organizer-code');
if (role && invitation) {
  const updateRole = () => { invitation.hidden = role.value !== 'organizer'; };
  role.addEventListener('change', updateRole);
  updateRole();
}

const applicationForm = document.querySelector('#application-form');
if (applicationForm && applicationForm.dataset.editable === 'true') {
  let dirty = false;
  const fields = Array.from(applicationForm.querySelectorAll('[data-minimum]'));
  const updateProgress = () => {
    let complete = 0;
    fields.forEach(field => {
      const done = field.value.trim().length >= Number(field.dataset.minimum);
      complete += Number(done);
      const item = document.querySelector(`[data-check="${field.id}"]`);
      if (item) {
        item.classList.toggle('done', done);
        item.querySelector('.check-icon').textContent = done ? '✓' : '○';
      }
    });
    const percent = Math.round(complete / fields.length * 100);
    document.querySelector('#completion').value = percent;
    document.querySelector('#progress-percent').textContent = percent + '%';
  };
  applicationForm.addEventListener('input', () => {
    dirty = true;
    document.querySelector('#save-state').textContent = 'Unsaved changes';
    updateProgress();
  });
  applicationForm.addEventListener('submit', () => { dirty = false; });
  window.addEventListener('beforeunload', event => {
    if (dirty) { event.preventDefault(); event.returnValue = ''; }
  });
  updateProgress();
}
