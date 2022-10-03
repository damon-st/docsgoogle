import DocumentSchema from "../models/document_model.js";
const createDoc = async (req, res) => {
  try {
    const { createdAt } = req.body;
    let document = new DocumentSchema({
      uid: req.user,
      title: "Untitled Document",
      createdAt,
    });

    document = await document.save();
    return res.status(200).send({
      status: "success",
      document,
    });
  } catch (e) {
    return res.status(500).send({
      status: "error",
      error: e.toString(),
      msg: "Error server",
    });
  }
};

const getDocs = async (req, res) => {
  try {
    let documents = await DocumentSchema.find({ uid: req.user });

    return res.status(200).send({
      documents,
      status: "success",
    });
  } catch (error) {
    return res.status(500).send({
      status: "error",
      error: e.toString(),
      msg: "Error server",
    });
  }
};
const docTitle = async (req, res) => {
  try {
    const { id, title } = req.body;
    const document = await DocumentSchema.findByIdAndUpdate(id, { title });
    return res.status(200).send({
      status: "success",
      document,
    });
  } catch (e) {
    return res.status(500).send({
      status: "error",
      error: e.toString(),
      msg: "Error server",
    });
  }
};
const getSingelDoc = async (req, res) => {
  try {
    let document = await DocumentSchema.findById(req.params.id);

    return res.status(200).send({
      document,
      status: "success",
    });
  } catch (error) {
    return res.status(500).send({
      status: "error",
      error: e.toString(),
      msg: "Error server",
    });
  }
};
export { createDoc, getDocs, docTitle, getSingelDoc };
