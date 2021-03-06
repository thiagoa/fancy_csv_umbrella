import 'phoenix_html'
import {Socket} from 'phoenix'

const container = document.getElementById('jobs-table')

if (container) {
  const socket = new Socket('/socket')

  JobsApp(socket, container).initialize()
}

function JobsApp(socket, container) {
  return {
    initialize() {
      socket.connect()

      const jobsTable = JobsTable(container)
      const channel = socket.channel('job_runner')

      channel.join()
        .receive('error', resp => { console.log('Unable to join', resp) })

      channel.on('initialize', ({ jobs: jobs }) => jobs.forEach(jobsTable.add))
      channel.on('add', jobsTable.add)
      channel.on('update', jobsTable.update)
    }
  }
}

function JobsTable(container) {
  const children = {}

  container.innerHTML = `
    <table class="table">
      <thead>
        <tr>
          <th>Job ID</th>
          <th>File name</th>
          <th>Nº Success</th>
          <th>Nº Error</th>
          <th>Output</th>
        </tr>
      </thead>
      <tbody>
      </tbody>
    </table>
  `

  function childTemplate(id, job) {
    return `
      <td class="id">${id}</td>
      <td class="filename">${job.filename}</td>
      <td class="ok">${job.ok}</td>
      <td class="error">${job.error}</td>
      <td class="output">${getOutput(job)}</td>
    `
  }

  function add({ id: id, data: job }) {
    const child = document.createElement('tr')

    child.className = 'job'
    child.innerHTML = childTemplate(id, job)

    children[id] = {
      ok: child.querySelector('.ok'),
      error: child.querySelector('.error'),
      output: child.querySelector('.output')
    }

    container.querySelector('tbody').insertAdjacentElement('afterbegin', child)
  }

  function update({ id: id, data: job }) {
    const child = children[id]

    child.ok.innerHTML = job.ok
    child.error.innerHTML = job.error
    child.output.innerHTML = getOutput(job)
  }

  function getOutput(job) {
    if (job.message) {
      return job.message
    }
    else {
      return job.output ? `<a href="${job.output}">Download</a>` : '-'
    }
  }

  return { add, update }
}
